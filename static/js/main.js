$(".module-endorse").on("click", function(){
  var $self = $(this);
  $.ajax({
    url: "/api/toggle-endorsement",
    type : "POST",
    dataType : "json",
    data : {id: $self.attr("data-module-id")},
  }).done(function(data){
    if (data.ok) {
      $self.toggleClass("endorsed");
    }
  })
});
