var animation_time = 500;

var loading = false;
var spincount = 0;

function transitionToResults() {
  loading = false;
  spincount = 0;
  $('div#frame').animate({
    left: '-100%',
    top: '-100%'
  }, animation_time, function() {});
}

function transitionToLogin() {
  loading = false;
  spincount = 0;
  $('div#frame').animate({
    left: '0%',
    top: '0%'
  }, animation_time, function() {});
}

function transitionToSignUp() {
  $('div#frame').animate({
    left: '0%',
    top: '-200%'
  }, animation_time, function() {});
}

function transitionToHome() {
  $('div#frame').animate({
    left: '0%',
    top: '-100%'
  }, animation_time, function() {});
}

function flipButton() {
  var home = $('iframe#home').contents().get(0);
  
  if (spincount > 10) {
    $('form', home).html("<span style='color:red'>" + 
        "Sorry, it looks like something went wrong &mdash; " +
        "please try again later.");
  }
  
  var t = (++spincount)%2 * 360;
  $('input.button', home).css('-webkit-transform', 'rotateY('+t+'deg)');
  if (loading) {
    setTimeout(flipButton, 1000);
  }
}

function showResults(q, l) {
  var mapView = $('iframe#map').contents().get(0).defaultView;
  var home = $('iframe#home').contents().get(0);
  
  $('div#noresults', home).detach();
  
  mapView.clearResults();
  mapView.q = q;
  mapView.l = l;
  mapView.loadResults(function() {
    var url = '/search?q='+q+'&l='+l;
    history.pushState({view: 'results', q : q, l : l}, mapView.title, url);
    transitionToResults();
  
  }, function(){
    loading = false;
    spincount = 0;

    $('div#inputform', home).after('<div id="noresults" style="text-align: center">' +
        'Sorry, we couldn\'t find any results for'+
        ' your query.</div>');
  });
}

window.onload = function() {
  
  var home = $('iframe#home').contents().get(0);
  document.title = home.title;
  
  $('form', home).submit(function(evt) {
    evt.preventDefault();
    
    loading = true;
    flipButton();
    
    var q = $('form input#q', home).val();
    var l = $('form input#l', home).val();
  
    showResults(q, l, true);
  });
  
  $('a.recent', home).click(function(evt) {
    evt.preventDefault();
    var q = evt.target.getAttribute('data-q');
    var l = evt.target.getAttribute('data-l');
    showResults($.URLDecode(q), $.URLDecode(l));
  });
  
  $('div#logintab a#sign_in').click(function(evt) {
    evt.preventDefault();
    history.pushState({view: 'login'}, 'Login', evt.target.getAttribute('href'));
    transitionToLogin();
  });
  
  $('div#logintab a#sign_up').click(function(evt) {
    evt.preventDefault();
    history.pushState({view: 'signup'}, 'Sign Up', evt.target.getAttribute('href'));
    transitionToSignUp();
  });
  
}

window.onpopstate = function(event) {
  var mapView = $('iframe#map').contents().get(0).defaultView;
  
  if (! event.state) {
	  transitionToHome();
	} else if (event.state.view == 'results') {
	  if (mapView.q == event.state.q && mapView.l == event.state.l) {
	    transitionToResults();
	  } else {
	    showResults(event.state.q, event.state.l) 
	  }
	} else if (event.state.view == 'login') {
	  transitionToLogin();
	} else if (event.state.view == 'signup') {
	  transitionToSignUp();
	}
}
