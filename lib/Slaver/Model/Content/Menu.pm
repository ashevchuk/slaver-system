package Slaver::Model::Content::Menu;
use Moose;

BEGIN { extends 'Catalyst::Model' }

use MongoDB::OID;

__PACKAGE__->mk_accessors(qw|context|);

sub ACCEPT_CONTEXT {
  my ($self, $context, @args) = @_;
  $self->context($context);
  return $self;
}

sub get {
  my ($self, $config) = @_;

  my $context = $self->context;

  my $cache = $context->cache;

  my $result;

#    unless ( $result = $cache->get( 'menu' ) ) {
#	my $config;
  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');

  $config->{model} = $coll;

  $result = $self->tree($config);
  $cache->set('menu', $result);

  return $result;
}

sub get_by_id {
  my ($self, $node_id, $config) = @_;

  my $context = $self->context;

  my $cache = $context->cache;
  my $result;

#    unless ( $result = $cache->get( 'menu_id_' . $node_id ) ) {
#	my $config;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');

  $config->{model}   = $coll;
  $config->{node_id} = $node_id;

  $result = $self->tree($config);

  $cache->set('menu_id_' . $node_id, $result);

  return $result;
}

sub get_parent_by_id {
  my ($self, $node_id, $config) = @_;

  my $context = $self->context;

  my $cache = $context->cache;
  my $result;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');

  my $parent = $self->get_parent($node_id);

  $config->{model} = $coll;
  $config->{node_id} = $parent ? $parent : $node_id;

  $result = $self->tree($config);

  $cache->set('menu_id_' . $node_id, $result);

  return $result;
}

sub get_parent {
  my ($self, $id) = @_;

  my $context = $self->context;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');
  my $cat  = $coll->find_one({_id => MongoDB::OID->new(value => $id)});

  return $cat->{sub_id} if defined $cat;
}

sub alias_to_id {
  my ($self, $id) = @_;

  my $context = $self->context;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');
  my $cat  = $coll->find_one({alias => $id});

  return $cat->{_id}->value if defined $cat;
}

sub id_to_alias {
  my ($self, $id) = @_;

  my $context = $self->context;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');
  my $cat  = $coll->find_one({_id => $id});

  return $cat->{alias} if defined $cat;
}

sub by_id {
  my ($self, $id) = @_;

  my $context = $self->context;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');
  my $cat  = $coll->find_one({_id => $id});

  return $cat if defined $cat;
}

sub from_id {
  my ($self, $id) = @_;

  my $context = $self->context;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');
  my $cat  = $coll->find_one({alias => $id});

  return $cat if defined $cat;
}

sub path_to_by_id {
  my ($self, $id) = @_;

  my $context = $self->context;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');
  my $cat  = $coll->find_one({_id => $id});

  my $menu = $self->get();
  my $path = $self->render_path({tree => $menu, id => $cat->{_id}});

  return $path;
}

sub path_to {
  my ($self, $id) = @_;

  my $context = $self->context;

  my $db   = $context->model('Data::Provider')->db('content');
  my $coll = $db->get_collection('menu');
  my $cat  = $coll->find_one({alias => $id});

  my $menu = $self->get();
  my $path = $self->render_path({tree => $menu, id => $cat->{_id}});

  return $path;
}

sub render_path {
  my $self   = shift;
  my $config = shift;

  my $menu = $config->{tree};
  my $id   = $config->{id};
  my $path = $config->{path};

  foreach my $menu_item (keys %{$menu->{nodes}}) {
    $config->{path} = $menu->{nodes}->{$menu_item}->{path}
      if $id eq $menu_item;

    if ($menu->{nodes}->{$menu_item}->{items}) {
      $config->{tree} = $menu->{nodes}->{$menu_item}->{items};
      $config->{id}   = $id;
      $self->render_path($config);
    }
  }

  return $config->{path};
}

sub tree {
  my $self   = shift;
  my $config = shift;

  $config->{limit}->{depth} = 32 unless defined $config->{limit}->{depth};
  $config->{limit}->{depth}--;

  unless (defined $config->{model}) {
    my $context = $self->context;
    my $db   = $context->model('Data::Provider')->db('content');
    my $coll = $db->get_collection('menu');
    $config->{model} = $coll;
  }

  return $self->depth_tree($config);
}

sub depth_tree {
  my $self   = shift;
  my $config = shift;

  my $field_id          = $config->{field}->{id}          || 'id';
  my $field_sub_id      = $config->{field}->{sub_id}      || 'sub_id';
  my $field_caption     = $config->{field}->{caption}     || 'caption';
  my $field_role        = $config->{field}->{role}        || 'role';
  my $field_description = $config->{field}->{description} || 'description';
  my $field_owner       = $config->{field}->{owner}       || 'owner';
  my $field_alias       = $config->{field}->{alias}       || 'alias';
  my $field_uri         = $config->{field}->{uri}         || 'uri';
  my $field_icon        = $config->{field}->{icon}        || 'icon';

  my $menu;

  my $parent = $config->{node_id};
  my $path   = $config->{path};

  my $cursor = $config->{model}->find({$field_sub_id => $config->{node_id} || ''});

  while (my $menu_item = $cursor->next) {
    push(@{$menu->{order}}, $menu_item->$field_id);

    $config->{node_id} = $menu_item->$field_id;

    my $new_array = $path;

    $parent = defined $parent ? $parent : '';

    push(
      @{$new_array},
      { parent      => $parent,
        id          => $menu_item->$field_id,
        caption     => $menu_item->$field_caption,
        role        => $menu_item->$field_role,
        description => $menu_item->$field_description,
        owner       => $menu_item->$field_owner,
        alias       => $menu_item->$field_alias,
        icon        => $menu_item->$field_icon
      }
    ) unless grep(/^${parent}/i, @{$new_array});


    $menu->{nodes}->{$menu_item->$field_id}->{parent}      = $parent;
    $menu->{nodes}->{$menu_item->$field_id}->{id}          = $menu_item->$field_id;
    $menu->{nodes}->{$menu_item->$field_id}->{caption}     = $menu_item->$field_caption;
    $menu->{nodes}->{$menu_item->$field_id}->{role}        = $menu_item->$field_role;
    $menu->{nodes}->{$menu_item->$field_id}->{description} = $menu_item->$field_description;
    $menu->{nodes}->{$menu_item->$field_id}->{owner}       = $menu_item->$field_owner;
    $menu->{nodes}->{$menu_item->$field_id}->{uri}         = $menu_item->$field_uri;
    $menu->{nodes}->{$menu_item->$field_id}->{alias}       = $menu_item->$field_alias;
    $menu->{nodes}->{$menu_item->$field_id}->{icon}        = $menu_item->$field_icon;
    $menu->{nodes}->{$menu_item->$field_id}->{path}        = ();

    my $path_to_root = $self->get_path({%{$config}, item_id => $menu_item->$field_sub_id});

    $path_to_root = [] unless defined $path_to_root;

    @{$path_to_root} = reverse @{$path_to_root};

    push(
      @{$path_to_root},
      { caption     => $menu_item->$field_caption,
        id          => $menu_item->$field_id,
        role        => $menu_item->$field_role,
        owner       => $menu_item->$field_owner,
        alias       => $menu_item->$field_alias,
        description => $menu_item->$field_description,
        uri         => defined $menu_item->$field_uri
        ? $menu_item->$field_uri
        : sprintf("/%s/%s/", $menu_item->$field_role, $menu_item->$field_alias),
        icon => $menu_item->$field_icon,
      }
    );

    $menu->{nodes}->{$menu_item->$field_id}->{path} = $path_to_root;

    if ($config->{limit}->{depth} > 0) {

      my $sub_item = $self->depth_tree(
        { %{$config},
          path  => $new_array,
          limit => {depth => $config->{limit}->{depth} - 1}
        }
      );
      $menu->{nodes}->{$menu_item->$field_id}->{items} = $sub_item
        if defined $sub_item;
    }

  }

  return $menu;
}

sub get_path {
  my $self   = shift;
  my $config = shift;

  my $field_id          = $config->{field}->{id}          || '_id';
  my $field_sub_id      = $config->{field}->{sub_id}      || 'sub_id';
  my $field_caption     = $config->{field}->{caption}     || 'caption';
  my $field_role        = $config->{field}->{role}        || 'role';
  my $field_description = $config->{field}->{description} || 'description';
  my $field_owner       = $config->{field}->{owner}       || 'owner';
  my $field_alias       = $config->{field}->{alias}       || 'alias';
  my $field_uri         = $config->{field}->{uri}         || 'uri';
  my $field_icon        = $config->{field}->{icon}        || 'icon';

  my $menu;

  my $cursor = $config->{model}
    ->find({$field_id => MongoDB::OID->new(value => $config->{item_id})});
  while (my $menu_item = $cursor->next) {
    push(
      @{$menu},
      { caption => $menu_item->$field_caption,
        id      => $menu_item->$field_id->value,
        role    => $menu_item->$field_role,
        owner   => $menu_item->$field_owner,
        uri     => defined $menu_item->$field_uri
        ? $menu_item->$field_uri
        : sprintf("/%s/%s/",
          $menu_item->$field_role, $menu_item->$field_alias),
        alias       => $menu_item->$field_alias,
        icon        => $menu_item->$field_icon,
        description => $menu_item->$field_description
      }
    );

    if ($menu_item->$field_sub_id) {
      $config->{item_id} = $menu_item->$field_sub_id;
      my $sub_id = $self->get_path($config);
      foreach my $sub_id_item (@{$sub_id}) {
        push(@{$menu}, $sub_id_item);
      }
    }
  }

  return $menu;
}

__PACKAGE__->meta->make_immutable;

1;
