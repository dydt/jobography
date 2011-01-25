/* These vars are defined by the view.
var q = "<%= @query %>";
var l = "<%= @location %>";
var query_path = "<%= results_path %>";
var contact_path = "/fb_contacts";
var delayLoad = "<%= @delayLoad %>";*/

var map;

var jobs = [];
var job_markers = [];

var contacts = [];
var contact_load_index = 0;
var contact_markers = [];

var open_windows = [];

$('div#header h1 a').click(function(evt) {
  if (window != window.top) {
    evt.preventDefault();
    window.top.history.back();
  }
});

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

function loadResults(onSuccess, onFailure) {
  $.ajax({
    url : query_path,
    type : 'get',
    data : {'q' : q, 'l' : l},
    success : function(results, req, status) {
      handleResults(results, req, status);
      if (results.length > 0) {
        if (onSuccess)
          onSuccess();
      } else {
        if (onFailure)
          onFailure();
      }
    }
  });
}

function handleResults(results, req, status) {
  var bounds = new google.maps.LatLngBounds();
  for (var i = 0; i < results.length; i++) {
    job = results[i].job;
    
    if (job.lat == null || job.long == null) {
      continue;
    }
    
    var marker = addResult(job, i);
    bounds.extend(marker.position);
    job_markers.push(marker);
  }
  
  setupResultsBox();
  createNewSearchBox();
  
  if (results.length > 0) {
    map.panToBounds(bounds);
    map.fitBounds(bounds);
  }
}

function addResult(job, index) {
  var innerText = 
    "<p class=result_title><a href=\""+ job.source + "\" target='window"+index+"'>" +
      job.title + "&mdash;" + job.company + ", " +
      job.city + ", " + job.state + "</a></p>" + 
    "<p class=result_text>" + job.desc + "</p>";
  
  $('div#results_list ul#results').append(
    "<li data-index=\"" + index + "\">" +
      innerText +
    "</li>");
  
  var marker = new google.maps.Marker({
    map: map,
    animation: google.maps.Animation.DROP,
    position: new google.maps.LatLng(job.lat, job.long),
    title: job.title + ' - ' + job.company,
    icon: '/images/marker-red.png'
  });
  
  marker.infowindow = new google.maps.InfoWindow({
    zIndex: 3,
    maxWidth: 375,
  });
  
  marker.infowindow.setContent(
    "<div class='job_marker'>" +
      innerText +
    "</div>");
  
  google.maps.event.addListener(marker, 'click', function() {
    while (open_windows.length > 0) {
      open_windows.pop().close();
    }
    open_windows.push(marker.infowindow);
    marker.infowindow.open(map, marker);
  });
  
  return marker;
}

function clearResults() {
  for (var i = 0; i < job_markers.length; i++) {
    job_markers[i].setMap(null);
  }
  job_markers = [];
  
  for (var i = 0; i < contact_markers.length; i++) {
    contact_markers[i].setMap(null);
  }
  contact_markers = [];
  
  $('div#results_list ul').html('');
}

function loadContacts() {
  $.ajax({
    url: contacts_path,
    type: 'get',
    data: {},
    
    success: function(results, req, status) {
      for (var i = 0; i < results.length; i++) {
        contacts.push(results[i]);
      }
      getContacts();
    }
  });
}

function getContacts() {
  if (contact_load_index >= contacts.length) {
    return;
  }
  var c = contacts[contact_load_index]
  $.ajax({
    url: contacts_path + '/' + c.id,
    type: 'get',
    data: {},
    
    success: function(results, req, status) {
      var c = results['facebook_contact']
      contacts[contact_load_index++] = c;
      addContact(c);
      getContacts();
    }
  })
}

function addContact(c) {
  var marker = new google.maps.Marker({
    map: map,
    animation: google.maps.Animation.DROP,
    position: new google.maps.LatLng(c.lat, c.long),
    title: c.name,
    icon: '/images/marker-red.png'
  });
  
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

function setupResultsBox() {
  $('div#results_list ul#results li').click(function(evt) {
    for (var i = 0; i < job_markers.length; i++) {
      job_markers[i].setIcon('/images/marker-red.png');
      job_markers[i].setZIndex(1);
    }
    var i = $(evt.target).closest('li').get(0).getAttribute("data-index");
    job_markers[i].setZIndex(5);
    job_markers[i].setIcon('/images/marker-blue.png');
    map.panTo(job_markers[i].getPosition());
  });
  
  $('div#results_box a#toggle_results_box').click(function(evt) {
    evt.preventDefault();
    var a = $('a#toggle_results_box')
    if (a.attr('data-state') == 'hidden') {
      $('div#results_box').animate({right : '7px'}, 500, null);
      a.attr('data-state', 'shown');
      $('img', a).attr('src', '/images/arrow-right.png');
    } else {
      $('div#results_box').animate({right : '-251px'}, 500, null);
      a.attr('data-state', 'hidden');
      $('img', a).attr('src', '/images/arrow-left.png');
    }
  });
}

function createNewSearchBox() {
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
          'near <input name="q" type="text" placeholder="'+l+'">' +
          '<input type="submit" value="go!">' +
      '</form>');
  });
}
