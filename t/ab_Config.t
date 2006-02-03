use strict;
use warnings;

use Test::More qw(no_plan); 
use CGI::AppBuilder::Message qw(:echo_msg); 

use CGI::AppBuilder::Config;
my $class = 'CGI::AppBuilder::Config';
my $obj = CGI::AppBuilder::Config->new; 

isa_ok($obj, "CGI::AppBuilder::Config");

my @md = @CGI::AppBuilder::Config::EXPORT_OK;
foreach my $m (@md) {
    ok($obj->can($m), "$class->can('$m')");
}

diag("Test eval_var method...");
my $cfg = {fn=>'John', ln=>'Smith', full_name => "\$fn \$ln",
    addr1=>"111 MKT St", city=>"PHL", zip_code=>"19102",
    address => "\$addr1, \$city, PA \$zip_code",
    fname => "\$full_name", 
    contact=>"\$full_name <address>\$address</address> \$logo",
    hh=>'$ENV{HTTP_HOST}',usr=>'$ENV{USER}',
    fn2=>'$hr{first_name}', ln2=>'$hr{last_name}',
    a=>10, b=>"\$a+2", c=>"2*(\$b)", d=>"\$c-1",
    e=>"3*(\$d)",
    };
my $ar = { %$cfg }; 
my $mk = {}; 
my $hr = { logo => 'http://mydomain.com/images/logo.gif', 
    first_name=>'John', last_name=>'Smith'
    };
$mk->{p1} = $obj->eval_var($ar, $hr);
$mk->{p2} = $obj->eval_var($ar, $hr);
is($ar->{full_name}, "$cfg->{fn} $cfg->{ln}", "p1");
is($ar->{fname}, "$cfg->{fn} $cfg->{ln}", "p2");
# $obj->disp_param($ar); 
# $obj->disp_param($mk); 

diag("Test eval_named_var method...");
$ENV{HTTP_HOST}='test.com:8000';
$ENV{USER}='htu';
$mk->{ENV} = $obj->eval_named_var($ar, 'ENV');
$mk->{hr}  = $obj->eval_named_var($ar, 'hr', $hr);
is($ar->{hh}, $ENV{HTTP_HOST}, "ENV http_host");
is($ar->{usr},$ENV{USER}, "ENV user");
is($ar->{fn2}, $hr->{first_name}, "hr->{fn2}");
is($ar->{ln2}, $hr->{last_name}, "hr->{ln2}");
# $obj->disp_param($ar); 
# $obj->disp_param($mk); 

diag("Test eval_variables method...");
my $m2 = $obj->eval_variables($cfg,$hr);
is(eval $cfg->{b}, 12, "EV->{b}");
is(eval $cfg->{c}, 24, "EV->{c}");
is(eval $cfg->{d}, 23, "EV->{d}");
is(eval $cfg->{e}, 69, "EV->{e}");
is($cfg->{full_name}, "$cfg->{fn} $cfg->{ln}", "pass 1");
is($cfg->{fname}, "$cfg->{fn} $cfg->{ln}", "pass 2");
is($cfg->{hh}, $ENV{HTTP_HOST}, "ENV http_host");
is($cfg->{usr},$ENV{USER}, "ENV user");
is($cfg->{fn2}, $hr->{first_name}, "hr->{fn2}");
is($cfg->{ln2}, $hr->{last_name}, "hr->{ln2}");
# $obj->disp_param($cfg); 
# $obj->disp_param($m2); 

1;

