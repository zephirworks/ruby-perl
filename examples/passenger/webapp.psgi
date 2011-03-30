my $app = sub {
  print STDERR "just in app\n";
  my $env = shift;
  my @ret;

  print STDERR "\$env = '$env'";
  while (my ($k, $v) = each %$env) {
    push(@ret, "<p>key: $k, value: $v.</p>\n");
  }

  return [
      '200',
      [ 'Content-Type' => 'text/plain' ],
      \@ret, # or IO::Handle-like object
  ];
}