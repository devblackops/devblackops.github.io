---
layout: null
---

var host = "devblackops.io";
if ((host == window.location.host) && (window.location.protocol != "https:"))
  window.location.protocol = "https";

$(document).ready(function () {
  $('.show-disqus').on('click', function (e) {
    e.preventDefault();
    var $btn = $('.disqus-hidden');

    $.ajax({
      type: 'GET',
      url: '//' + disqus_shortname + '.disqus.com/embed.js',
      dataType: 'script',
      cache: true,
      beforeSend: function() {
        $btn.html('Loading..');
      }
    }).done(function() {
      $btn.delay(1200).fadeOut().delay(500).html('');
    });
  });

  SocialShareKit.init();

  $('.btn-mobile-menu').click(function () {
    $('.navigation-wrapper').toggleClass('visible animated bounceInDown')
    $('.btn-mobile-menu__icon').toggleClass('icon-list icon-x-circle animated fadeIn')
  })
})
