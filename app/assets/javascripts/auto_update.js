//最終的にターンプレイヤが変わったらページを切り替える
  $(function(){
    function reload(){
       location.reload();
    }
    function cleanboard(){
          //$('card_0').removeClass('opacity');
          $('input.board_card').val('　');
          $('input.board_card').removeClass('opacity');

    }
      function alltext(text,height,width){

        $('#input_'+height+'_'+width).val(text);
          $('#message').html('失敗');
      }
     function textadd(text,height,width,count){
         $('#input_'+height+'_'+width).val(text);
         $('#input_'+height+'_'+width).addClass('opacity');
         $('#message').html('成'+count+'功');
     }

     $(function(){
         setInterval(update, 1000);
     });

     function update(){
         var  log_id = $('#logcount').data('id');
         var turn_id = $('#turncount').data('id');
         $.ajax({
             url: location.href,
             type: 'GET',
             data:{logid: log_id},
             dataType: 'json'
         })
         .always(function(data){
           var count = 0;

                 $(data).each(function(){
                   if(this.id === 1){
                      count += 1;
                   }
                   if(this.id === 1 && this.turn === turn_id +1){
                       reload();
                   }
                 });

                 if(count === 1){
                     cleanboard();
                     $(data).each(function(index,value){
                           alltext(this.moji,this.height,this.width);
                     });
                 }else{
                     $(data).each(function(index,value){
                           textadd(value.moji,value.height,value.width,count);

                     });
                 }

         })
     }

  });
