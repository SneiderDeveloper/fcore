String conciergeRoleLabel(int index) {
  switch (index) {
    case 0:
      return 'Primary Concierge';
    case 1:
      return 'Secondary Concierge';
    case 2:
      return 'Tertiary Concierge';
    default:
      return 'Concierge #${index + 1}';
  }
}
