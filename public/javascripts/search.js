/* These vars are defined by the view.
var q = "<%= @query %>";
var l = "<%= @location %>";
var query_path = "<%= results_path %>";
var contact_path = "/fb_contacts";
var delayLoad = "<%= @delayLoad %>";*/

var map;
var markers = [];
var open_windows = [];
var index = 0;
var contacts = [];
var cmarkers = [];

function loadMap() {
  var center = new google.maps.LatLng(39.109, -94.589);
  
  var options = {
    zoom: 4,
    center: center,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    panControl: true,
    panControlOptions: {
      position: google.maps.ControlPosition.LEFT_CENTER
    },
    zoomControl: true,
    zoomControlOptions: {
      position: google.maps.ControlPosition.LEFT_CENTER
    },
    mapTypeControl: false,
    streetViewControl: true
  };
  
  map = new google.maps.Map($("div#map").get(0), options);
  if (delayLoad == '') {
    loadResults(function(){}, function(){ 
      alert("Sorry, we couldn't find any results for your query.");
    });
  }
}

function loadResults(onSucess, onFailure) {
  $.ajax({
    url : query_path,
    type : 'get',
    data : {'q' : q, 'l' : l},
    
    success : function(results, req, status) {
      var bounds = new google.maps.LatLngBounds();
      for (var i = 0; i < results.length; i++) {
        job = results[i].job;
        
        if (job.lat == null || job.long == null) {
          continue;
        }
        
        var marker = new google.maps.Marker({
          map: map,
          animation: google.maps.Animation.DROP,
          position: new google.maps.LatLng(job.lat, job.long),
          title: job.title + ' - ' + job.company 
        });
        
        createJobInfoWindow(job, marker, map);
        
        bounds.extend(marker.position);
        
        markers.push(marker);
      }
      
      if (results.length > 0) {
        map.panToBounds(bounds);
        map.fitBounds(bounds);
        
        var again_text = 'You searched for ' + q +
              ' jobs';
        if (l != '') {
          again_text += ' near ' + l;
        }
        again_text += '.&nbsp;&nbsp;<a href="/">Search again?</a>';
        
        $('div#search_again').html(again_text);
        $('div#search_again').css({display: 'block'});
        $('div#search_again a').click(function(evt) {
          evt.preventDefault();
          $('div#search_again').html(
            '<form id="search" method="get">'+
                '<input name="q" type="text" placeholder="'+q+'">' +
                '<input name="q" type="text" placeholder="'+l+'">' +
                '<input type="submit" value="go!">' +
            '</form>');
        });
        
        onSucess();
      } else {
        onFailure();
      }
    }
  });
}

function createJobInfoWindow(job, marker, map) {
  var contentString = '<div class="job_infowindow"><p><strong><a href="'+job.source+'">' + 
      job.title+'</a></strong><br />'+job.company+'<br />'+
      job.desc+'<br /><em>'+job.city+', '+job.state+'</em>'+' '+job.date+"</p></div>";
  
  marker.infowindow = new google.maps.InfoWindow({
    content: contentString,
    zIndex: 3,
    maxWidth: 375,
  });
  

  google.maps.event.addListener(marker, 'click', function() {
    while (open_windows.length > 0) {
      open_windows.pop().close();
    }
    open_windows.push(marker.infowindow);
    marker.infowindow.open(map, marker);
  });
}

function clearResults() {
  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(null);
  }
  markers = [];
}

function loadContacts() {
  $.ajax({
    url: contact_path,
    type: 'get',
    data: {},
  
    success : function(results, req, status) {
      for (var i = 0; i < results.length; i++) {
        var c = results[i].facebook_contact;
        if (c.location && !(c.location == '')) {
          contacts.push(results[i].facebook_contact);      
        }
      }
      syncGeocoding(contacts[index]);
    }
  });
}

function syncGeocoding(c) {
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode( {'address' : c.location}, function(latlngs, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      var marker = new google.maps.Marker({
        map: map,
        animation: google.maps.Animation.DROP,
        position: latlngs[0].geometry.location,
        title: c.name,
      });
      createContactInfoWindow(c, marker, map);
      cmarkers.push(marker);
    } else {
      setTimeout(function() {syncGeocoding(c)}, 500);
    }
    if (index < contacts.length-1) {
      setTimeout(function() {      
        syncGeocoding(contacts[++index]);
      }, 500);
    }
  });    
}

function createContactInfoWindow(c, marker, map) {
  var contentString = '<div class="contactWindow"><p><h4>'+c.name+
                      '</h4></p><p><img src=graph.facebook.com/'+c.facebook_id+
                      '/picture?type=small';
  
  marker.infowindow = new google.maps.InfoWindow({
    content: contentString
  });
  
  google.maps.event.addListener(marker, 'click', function() {
    while (open_windows.length > 0) {
      open_windows.pop().close();
    }
    open_windows.push(marker.infowindow);
    marker.infowindow.open(map, marker);
  });
}
