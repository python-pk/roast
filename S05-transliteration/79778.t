use Test;
plan 1;


is "this sentence no verb".trans( / \s+ / => " " ), 'this sentence no verb',"got expected string"  ;

# vim: expandtab shiftwidth=4
