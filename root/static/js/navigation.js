jQuery(document).ready(function() {
$('.dropdown-submenu > a').submenupicker();

function make_current_link() {
    var $location = document.location.pathname;
    var $paged_idx = $location.indexOf('/page');

    if($paged_idx > 0) {
        $location = $location.substr(0, $paged_idx + 1);
    }
    jQuery("a.tree-link").each(function(idx, link) {
	if(jQuery(link).attr('href') == $location) {
	    jQuery(link).addClass('link-current-pathname')
	}
    });
}

function make_parents_mark() {
    jQuery('li ul').parent().children('a').addClass('link-bold');
}

function make_code_blocks_toggle() {
    jQuery(".code-container-title").bind('click', function(event) {
	jQuery(event.currentTarget).parent().children(".code").slideToggle();
	jQuery(event.currentTarget).children(".toggle").toggle();
    });
}

function make_code_blocks_scrollable() {
    $('.code').jScrollPane({showArrows: true, hideFocus: true});
}

function make_code_blocks_sizable() {
    jQuery('.jspContainer').resizable({
	alsoResize: ".jspScrollable",
	containment: "#content",
	minWidth: "100%",
	maxWidth: "100%",
	minHeight: "120",
	resize: function( event, ui ) {
	    jQuery(event.target).parent('.jspScrollable').data('jsp').reinitialise();
	}
    });
    //jQuery('.jspContainer').resizable({alsoResize: ".jspScrollable", containment: "#content", stop: function( event, ui ) { jQuery(event.target).parent('.jspScrollable').data('jsp').reinitialise(); }});
}

make_current_link();
make_parents_mark();
make_code_blocks_toggle();
make_code_blocks_scrollable();
make_code_blocks_sizable();

$('[data-toggle="popover"]').popover({
    html : true,
    trigger: 'hover',
    'placement': 'top'
});

$('.expander').click(function(){ $($(this).parent().children('.expandable')).toggle(); });

function load_comments(comments, context) {
    $.ajax({
	type: "POST",
	url: "/service/ajax/json/content/comment/load",
	contentType: "application/json",
	crossDomain: true,
	dataType: "html",
	processData: false,
	context: context,
	data: JSON.stringify(comments),
	xhrFields: {
	    withCredentials: true
	}
    }).done(function( data ) {
	var id = $(this).data('document-id');
	$('#comments-section-'+id).data('loaded-comments', true);
	$('#comments-section-'+id).html(data);
    });
};

$('.comments-toggle-show').click(function(event) {
    event.preventDefault();
    var id = $(this).data('document-id');
    var loaded_comments = $('#comments-section-'+id).data('loaded-comments');

    if ( !loaded_comments ) {
	load_comments({ document_id: id }, this);
    }

    $('#comments-panel-'+id).slideToggle();
});

function mark_vote(context, mark) {
    var id = $(context).data('document-id');

    $.ajax({
	type: "POST",
	url: "/service/ajax/json/content/vote/mark",
	contentType: "application/json",
	crossDomain: true,
	dataType: "json",
	processData: false,
	context: context,
	data: JSON.stringify({ document_id : id, vote : mark }),
	xhrFields: {
	    withCredentials: true
	}
    }).done(function( data ) {
	var id = $(this).data('document-id');
	$('#like-toggle-'+id).children('.vote-mark').html(data.likes);
	$('#dislike-toggle-'+id).children('.vote-mark').html(data.dislikes);
    });
};

function add_comment(comment, context) {
    $.ajax({
	type: "POST",
	url: "/service/ajax/json/content/comment/add",
	contentType: "application/json",
	crossDomain: true,
	dataType: "json",
	processData: false,
	context: context,
	data: JSON.stringify(comment),
	xhrFields: {
	    withCredentials: true
	}
    }).done(function( data ) {
	var id = $(this).data('document-id');
	this.reset();
	load_comments({ document_id: id }, this);
    });
};


$('.like-toggle').click(function(event) {
    event.preventDefault();
    mark_vote(this, 1);
});

$('.dislike-toggle').click(function(event) {
    event.preventDefault();
    mark_vote(this, -1);
});

$('.comment-submit-form').submit(function(event) {
    event.preventDefault();
    var id = $(this).data('document-id');
    var name = $($(this).find("[name='name']:input")[0]).val();
    var message = $($(this).find("[name='message']:input")[0]).val();
    add_comment({ document_id: id, name: name, message: message }, this);
});

});
