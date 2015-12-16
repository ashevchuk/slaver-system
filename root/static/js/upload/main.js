$(function () {
    'use strict';

    var upload_slots = { };

    var fileupload = $('#fileupload').fileupload({
        xhrFields: { withCredentials: true },
        url: '/file/upload/broker/put',
	maxChunkSize: 10000000,
	maxRetries: 100,
	retryTimeout: 500,
	multipart: false,
	dataType: "",
	limitConcurrentUploads: Math.floor( CLUSTER_HOSTS_MAX_HOTS / 2 ) + 2,
	singleFileUploads: true,
	limitMultiFileUploads: Math.floor( CLUSTER_HOSTS_MAX_HOTS / 2 ) + 2,
	disableValidation: true,
	beforeSend: function(e, data, index, xhr, handler, callback) {
	    var filename = data.files[0].lastModified + data.files[0].name;
	    var sessionID = $.base64.encode(filename).replace(/\+|=|\//g, '');

	    // Set the required headers for the nginx upload module
	    e.setRequestHeader("Session-ID", sessionID);
	    e.setRequestHeader("X-Requested-With", "XMLHttpRequest");

	    return true;
	},
	submit: function (e, data) {
	    var $this = $(this);

	    var filename = data.files[0].lastModified + data.files[0].name;
	    var sessionID = $.base64.encode(filename).replace(/\+|=|\//g, '');

	    if ( !upload_slots[sessionID] ) {
		upload_slots[sessionID] = GET_CLUSTER_HOST();
	    }

	    $this.fileupload( { url : '//' + upload_slots[sessionID] + '/file/upload/broker/put' } );

	    return true;
	}
    } );

    $('#fileupload').fileupload('option', 'filesCount', 0);

    $('#fileupload')
	.bind('fileuploadadd', function (e, data) {
	    if (data.files) {
		var filesCount = $('#fileupload').fileupload('option', 'filesCount');
		$('#fileupload').fileupload('option', 'filesCount', filesCount + data.files.length);

		$("#btn-upld-upload").show();
		$("#btn-upld-cancel").show();
	    }
	    else {
		$("#btn-upld-cancel").hide();
		$("#btn-upld-upload").hide();
	    }
	})
	.bind('fileuploaddone', function (e, data) {
	    $('#fileupload').fileupload('option', 'filesCount', 0);
	    $("#btn-upld-upload").hide();
	    $("#btn-upld-cancel").hide();

	})
	.bind('fileuploadfail', function (e, data) {
	    if (data.files) {
		var filesCount = $('#fileupload').fileupload('option', 'filesCount');
		$('#fileupload').fileupload('option', 'filesCount', filesCount - data.files.length);
	    }

	    var filesCount = $('#fileupload').fileupload('option', 'filesCount');

	    if (filesCount > 0) {
		$("#btn-upld-upload").show();
		$("#btn-upld-cancel").show();
	    }
	    else {
		$("#btn-upld-cancel").hide();
		$("#btn-upld-upload").hide();
	    }
	})
	.bind('fileuploadstart', function (e) {
	    $("#btn-upld-upload").hide();
	    $("#btn-upld-cancel").show();
	})
	.bind('fileuploadstop', function (e) {
	    $('#fileupload').fileupload('option', 'filesCount', 0);
	    $("#btn-upld-upload").hide();
	    $("#btn-upld-cancel").hide();
	})
	.bind('fileuploadalways', function (e, data) {
	    var filename = data.files[0].lastModified + data.files[0].name;
	    var sessionID = $.base64.encode(filename).replace(/\+|=|\//g, '');

	    delete upload_slots[sessionID];

	    $("#btn-upld-upload").hide();
	    $("#btn-upld-cancel").hide();
	})
	.bind('fileuploadsubmit', function (e, data) {
	    if (data.files) {
		$("#btn-upld-upload").hide();
		$("#btn-upld-cancel").show();
	    }
	    else {
		$("#btn-upld-cancel").hide();
		$("#btn-upld-upload").hide();
	    }
	})
	.bind('fileuploadchange', function (e, data) {
	});

});
