var socket = io(window.location.hostname + ':3001');
var uploader = new SocketIOFileUpload(socket);
var spinner;


socket.on('prediction', function(msg) {
    // $('#spinner').data('spinner').stop();

    console.log('message: ' + msg);
    setTimeout(function() { $('#spinner').fadeOut(); }, 200);
    var results = msg.split(" ").map(function(x){
        return parseFloat(x);
    });
    results.pop()
    var context = document.getElementById("result-chart").getContext("2d");
    var data = {
        labels: ["Mateusz", "Janusz", "Rafał"],
        datasets: [
            {
                fillColor : "rgba(255,255,255,0.9)",
                strokeColor : "rgba(255,255,255,0.9)",
                data : results
            }
        ]
    };

    var options = {
        //Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
        scaleBeginAtZero : true,

        //Boolean - Whether grid lines are shown across the chart
        scaleShowGridLines : true,

        //String - Colour of the grid lines
        scaleGridLineColor : "rgba(0,0,0,.05)",

        //Number - Width of the grid lines
        scaleGridLineWidth : 1,

        //Boolean - Whether to show horizontal lines (except X axis)
        scaleShowHorizontalLines: true,

        //Boolean - Whether to show vertical lines (except Y axis)
        scaleShowVerticalLines: true,

        //Boolean - If there is a stroke on each bar
        barShowStroke : true,

        //Number - Pixel width of the bar stroke
        barStrokeWidth : 2,

        //Number - Spacing between each of the X value sets
        barValueSpacing : 5,

        //Number - Spacing between data sets within X values
        barDatasetSpacing : 1,

        scaleFontColor: "#ffffff",

        scaleFontSize: 19,

        //String - A legend template
        legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].fillColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"

    }
    var result_chart = new Chart(context).Bar(data, options);
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
        spinner = new Spinner(opts).spin(target);
    });

})
