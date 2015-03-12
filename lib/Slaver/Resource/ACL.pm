package Slaver::Resource::ACL;
use Moose::Role;

Slaver->allow_access($_) for
qw(
/default
/index
/admin/content/article/manager/create
/cache/data/files
/category/dodie
/file/upload/broker/get
/file/upload/broker/put
/file/upload/broker/slurp
/locale
/localize
/auth/login
/user/register
/user/registration
/user/repair
/search
/service/ajax/json/content/comment/add
/service/ajax/json/content/comment/load
/service/ajax/json/content/vote/mark
/sitemap/xml
/user/debug/session
/user/profile/avatar/get
/user/profile/avatar/upload
);

Slaver->allow_access_if($_, ['user']) for
qw(
/auth/logout
);

Slaver->allow_access_if($_, ['admin']) for
qw(
/auth/logout
/admin/system/log/show
/sys/stats
);

# Fall back to 'deny everything', i.e. if it isn't allowed by one of
# the preceding rules, it's forbidden.  The intent is that if I add an
# action and forget to put it into a rule, I'll soon find out.
#
#Slaver->deny_access('');

1;
