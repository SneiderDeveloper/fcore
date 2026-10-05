import 'dart:convert';

/// Builds a script that intercepts JavaScript-driven navigations (link
/// clicks, `window.open`, `location.assign/replace`) to any of
/// [redirectUrls] and reports them through the [channelName] JavaScript
/// channel instead of navigating.
///
/// Needed because some pages trigger deep links in ways that never reach
/// the web view's navigation delegate.
String buildRedirectBridgeScript({
  required List<String> redirectUrls,
  required String channelName,
}) {
  final encodedRedirects = jsonEncode(redirectUrls);
  final encodedChannel = jsonEncode(channelName);

  return '''
(() => {
  if (window.__appRedirectBridgeInstalled) return;
  window.__appRedirectBridgeInstalled = true;

  const channelName = $encodedChannel;

  const normalize = (value) => {
    let text = String(value || '');
    try {
      text = decodeURIComponent(text);
    } catch (_) {}
    text = text.trim().toLowerCase();
    while (text.endsWith('/')) {
      text = text.slice(0, -1);
    }
    return text;
  };

  const redirects = $encodedRedirects.map(normalize);

  const isRedirect = (value) => {
    const current = normalize(value);
    return redirects.some((redirect) => current.includes(redirect));
  };

  const notifyApp = (value) => {
    const channel = window[channelName];
    if (channel && typeof channel.postMessage === 'function') {
      channel.postMessage(String(value));
      return true;
    }
    return false;
  };

  const interceptRedirect = (value) => isRedirect(value) && notifyApp(value);

  document.addEventListener('click', (event) => {
    const element = event.target && event.target.closest
      ? event.target.closest('a, button, [role="button"]')
      : null;
    if (!element) return;

    const href = element.href || element.getAttribute('href') || element.dataset?.href || '';
    if (interceptRedirect(href)) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  const originalOpen = window.open;
  window.open = function (url, ...args) {
    if (interceptRedirect(url)) return null;
    return typeof originalOpen === 'function'
      ? originalOpen.call(window, url, ...args)
      : null;
  };

  const originalAssign = window.location.assign.bind(window.location);
  window.location.assign = (url) => {
    if (!interceptRedirect(url)) originalAssign(url);
  };

  const originalReplace = window.location.replace.bind(window.location);
  window.location.replace = (url) => {
    if (!interceptRedirect(url)) originalReplace(url);
  };
})();
''';
}
