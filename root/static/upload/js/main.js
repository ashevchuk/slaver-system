$(function () {
    'use strict';

    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload({
        // Uncomment the following to send cross-domain cookies:
        xhrFields: {withCredentials: true},
        url: '/file/upload/broker/put',
//	maxChunkSize: 10000000,
	limitConcurrentUploads: 8
    });

    // Enable iframe cross-domain access via redirect option:
    $('#fileupload').fileupload(
        'option',
        'redirect',
        window.location.href.replace(
            /\/[^\/]*$/,
            '/cors/result.html?%s'
        )
    );

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
	.bind('fileuploadalways', function (e) {
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

        // Load existing files:
//        $('#fileupload').addClass('fileupload-processing');
/*        $.ajax({
            // Uncomment the following to send cross-domain cookies:
            xhrFields: {withCredentials: true},
            url: $('#fileupload').fileupload('option', 'url'),
            dataType: 'json',
            context: $('#fileupload')[0]
        }).always(function () {
            $(this).removeClass('fileupload-processing');
        }).done(function (result) {
            $(this).fileupload('option', 'done')
                .call(this, $.Event('done'), {result: result});
        });
*/

});
