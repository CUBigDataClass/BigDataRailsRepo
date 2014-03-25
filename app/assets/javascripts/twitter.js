// Adding 500 Data Points
var map, pointarray, heatmap;
var taxiData = createDataArray();



function initialize() {
  createDataArray();

}

function createDataArray(){
    $.ajax({
      type: 'POST',
      url: '/twitter/lat_lon_sample.json',
      async: false
    })
    .done(function(data){
      parsedData = $.parseJSON(data);
      console.log(parsedData);
      // var coordArr = Array();
      
      // for (var i=0; i<parsedData.length; i++){
      //   coordArr[i] = new google.maps.LatLng(parsedData[i][0], parsedData[i][1]); 
      // }
      // console.log(coordArr);
      // var mapOptions = {
      //   zoom: 10,
      //   center: new google.maps.LatLng(39.7392, -104.9847),
      //   mapTypeId: google.maps.MapTypeId.SATELLITE
      // };

      // map = new google.maps.Map(document.getElementById('map-canvas'),
      //     mapOptions);

      // var pointArray = new google.maps.MVCArray(coordArr);

      // heatmap = new google.maps.visualization.HeatmapLayer({
      //   data: pointArray
      //   });

      // heatmap.setMap(map);

      });
  }

function toggleHeatmap() {
  heatmap.setMap(heatmap.getMap() ? null : map);
}

function changeGradient() {
  var gradient = [
    'rgba(0, 255, 255, 0)',
    'rgba(0, 255, 255, 1)',
    'rgba(0, 191, 255, 1)',
    'rgba(0, 127, 255, 1)',
    'rgba(0, 63, 255, 1)',
    'rgba(0, 0, 255, 1)',
    'rgba(0, 0, 223, 1)',
    'rgba(0, 0, 191, 1)',
    'rgba(0, 0, 159, 1)',
    'rgba(0, 0, 127, 1)',
    'rgba(63, 0, 91, 1)',
    'rgba(127, 0, 63, 1)',
    'rgba(191, 0, 31, 1)',
    'rgba(255, 0, 0, 1)'
  ]
  heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);
}

function changeRadius() {
  heatmap.set('radius', heatmap.get('radius') ? null : 20);
}

function changeOpacity() {
  heatmap.set('opacity', heatmap.get('opacity') ? null : 0.2);
}

google.maps.event.addDomListener(window, 'load', initialize);