
  $(function(){

     function textadd(text,height,width){
       $('#card_'+height+'_'+width).html(text);
       $('#card_'+height+'_'+width).addClass('opacity');

     }

     $(function(){
         setInterval(update, 5000);
     });

     function update(){
         var log_id = $('#logcount').data('id');
         $.ajax({
         url: location.href,
         type: 'GET',
         data:{logid: log_id},
         dataType: 'json'

         })
         .always(function(data){
           $(data).each(function(){
                 textadd(this.moji,this.height,this.width);
           });
         })

     }
  });
