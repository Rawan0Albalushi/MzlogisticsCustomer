const shellSectionRoots = <String>[
  '/home',
  '/shipments',
  '/jobs',
  '/invoices',
  '/payments',
  '/billing',
  '/profile',
];

String normalizeLocation(String path) {
  final withoutQuery = path.split('?').first;
  if (withoutQuery.length > 1 && withoutQuery.endsWith('/')) {
    return withoutQuery.substring(0, withoutQuery.length - 1);
  }
  return withoutQuery;
}

bool isShellSectionRoot(String path) {
  return shellSectionRoots.contains(normalizeLocation(path));
}

String sectionFallback(String path) {
  final location = normalizeLocation(path);
  if (location.startsWith('/trips')) return '/jobs';
  if (location.startsWith('/quotations')) return '/shipments';
  if (location.startsWith('/shipments')) return '/shipments';
  if (location.startsWith('/jobs')) return '/jobs';
  if (location.startsWith('/invoices')) return '/invoices';
  if (location.startsWith('/payments') || location.startsWith('/payment')) {
    return '/payments';
  }
  if (location.startsWith('/billing')) return '/billing';
  if (location.startsWith('/notifications')) return '/home';
  return '/home';
}
