var socket = io('localhost:3001');
var uploader = new SocketIOFileUpload(socket);


socket.on('prediction', function(msg){
    console.log('message: ' + msg);
});


$(function() {


    uploader.listenOnInput(document.getElementById("file-input"));

    $('#upload-button').on('click', function(e) {
        $('#file-input').trigger('click');
        e.preventDefault();
    });

    $(document).on('change', '#file-input', function(){
        $('#upload-button').fadeOut(400, function(){
            $('#spinner').fadeIn(600);
        });

        var opts = {
              lines: 13 // The number of lines to draw
            , length: 0 // The length of each line
            , width: 41 // The line thickness
            , radius: 0 // The radius of the inner circle
            , scale: 1 // Scales overall size of the spinner
            , corners: 0 // Corner roundness (0..1)
            , color: '#fff' // #rgb or #rrggbb or array of colors
            , opacity: 0 // Opacity of the lines
            , rotate: 0 // The rotation offset
            , direction: 1 // 1: clockwise, -1: counterclockwise
            , speed: 1.6 // Rounds per second
            , trail: 62 // Afterglow percentage
            , fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
            , zIndex: 2e9 // The z-index (defaults to 2000000000)
            , className: 'spinner' // The CSS class to assign to the spinner
            , top: '240px' // Top position relative to parent
            , left: '50%' // Left position relative to parent
            , shadow: false // Whether to render a shadow
            , hwaccel: false // Whether to use hardware acceleration
            , position: 'absolute' // Element positioning
        }

        var target = document.getElementById('spinner');
        var spinner = new Spinner(opts).spin(target);
    });

})
