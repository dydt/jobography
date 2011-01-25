/* These vars are defined by the view.
var q = "<%= @query %>";
var l = "<%= @location %>";
var query_path = "<%= results_path %>";
var contact_path = "/users/current/facebook_contacts";
var delayLoad = "<%= @delayLoad %>";*/

var map;

var jobs = [];
var job_markers = [];

var contacts_visible = false;
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

$('div#toggle_contacts a#toggle').click(function(evt) {
  evt.preventDefault();
  toggleContacts();
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
      alert("Sorry, we couldn't find any jobs like that.");
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
    nudgePosition(marker, job_markers);
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
      job.title + " &mdash; " + job.company + ", " +
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

function toggleContacts() {
  if (contacts_visible) {
    $('div#toggle_contacts a').html('Show contacts');
    for (var i = 0; i < contact_markers.length; i++) {
      contact_markers[i].setVisible(false);
    }
    contacts_visible = false;
  } else {
    contacts_visible = true;
    $('div#toggle_contacts a').html('Hide contacts');
    if (contacts.length > 0) {
      for (var i = 0; i < contact_markers.length; i++) {
        contact_markers[i].setVisible(true);
      }
    } else {
      loadContacts();
    }
  }
}

function loadContacts() {
  $('div#toggle_contacts').html(
    "<img alt='loading' style='position:relative; top:3px'" + 
      " src='/images/spinner.gif'>&nbsp;&nbsp;" +
    "Loading...");
  
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
    $('div#toggle_contacts').html(
      "<span class='fade'>Done!</span>");
    $('div#toggle_contacts span.fade').animate({opacity: '0'}, 1500, function() {
      $('div#toggle_contacts').html(
        "<a id='toggle' href='#'>Hide contacts</a>");
      $('div#toggle_contacts a#toggle').click(toggleContacts);
    })
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
  if (c.lat == null || c.long == null) {
    return;
  }
  
  var marker = new google.maps.Marker({
    map: map,
    animation: google.maps.Animation.DROP,
    position: new google.maps.LatLng(c.lat, c.long),
    title: c.name,
    icon: '/images/marker-green.png'
  });
  nudgePosition(marker, contact_markers);
  contact_markers.push(marker);
  
  var employmentsString = '';
  for (var i = 0; i < c.employments.length; i++) {
    employmentsString += "<li>";
    var e = c.employments[i];
    
    if (e.title) {
      employmentsString += c.employments[i].title;
    } else {
      employmentsString += "<span style='opacity:.5'>(unknown)</span>";
    }
    
    if (e.employer) {
      employmentsString += " &mdash; " + e.employer;
    }
    
    if (e.location) {
      employmentsString += ", " + e.location;
    }
  }
  
  var workHistoryString = "<p class='work_history'>";
  if (employmentsString.length > 0) {
    workHistoryString += "Work history:<ul>"+employmentsString+"</ul>";
  } else {
    workHistoryString += "No work history";
  }
  workHistoryString += "</p>"
  
  var contentString = 
  "<div class='contact_window'>" + 
      "<div class='contact_pic'>" +
        "<img alt='contact photo' src='http://graph.facebook.com/"+c.facebook_id+
                      "/picture?type=normal'>" +
      "<div class='contact_body'>" +
        "<h4><a href='http://www.facebook.com/profile.php?id="+c.facebook_id+
          "' target='window"+c.facebook_id+"'>"+c.name+"</a></h4>" +
        workHistoryString +
      "</div>" +
  "</div>";
    
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
    job_markers[i].setZIndex(20);
    job_markers[i].setIcon('/images/marker-blue.png');
    map.panTo(job_markers[i].getPosition());
  });
  
  $('div#results_box a#toggle_results_box').click(function(evt) {
    evt.preventDefault();
    var a = $('a#toggle_results_box')
    if (a.attr('data-state') == 'hidden') {
      $('div#results_box').animate({right : '7px'}, 500, null);
      a.attr('data-state', 'shown');
      $('img', a).attr('src', '/images/arrow-right1.png');
    } else {
      $('div#results_box').animate({right : '-253px'}, 500, null);
      a.attr('data-state', 'hidden');
      $('img', a).attr('src', '/images/arrow-left1.png');
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
          '<input name="q" type="text" placeholder="'+q+'" value="'+q+'">' +
          'near <input name="l" type="text" placeholder="'+l+'" value="'+l+'">' +
          '<input type="submit" value="go!">' +
      '</form>');
  });
}

function nudgePosition(marker, list) {
  var e = .00025;
  var nudgeDistance = 0.002;  // Approximately .5 miles in degrees
  var loc1 = marker.getPosition();
  for (var i = 0; i < list.length; i++) {
    var loc2 = list[0].getPosition();
    var dlat = Math.abs(loc1.lat() - loc2.lat());
    var dlng = Math.abs(loc1.lng() - loc2.lng());
    if (dlat > e && dlng > e) {
      var nlat = (Math.random() - .5) * nudgeDistance;
      var nlng = (Math.random() - .5) * nudgeDistance;
      
      marker.setPosition(new google.maps.LatLng(loc1.lat()+nlat, loc1.lng()+nlng));
      return;
    }
  }
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
