'use strict';
{

  $(function(){
    const session_id = $('#turncount').data('session_id');
    const turn_player_id = $('#turncount').data('turn_player_id');
    function btnHidden(id){
       document.getElementById(id).style.visibility = 'hidden';
    }
    function btnVisibility(id){
       document.getElementById(id).style.visibility = 'visible';

    }
    function reload(){
       location.reload();
    }
    function cleanboard(){
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

      $(function(){
          setInterval(aggregate, 1000);
      });


     function update(){



         $.ajax({
             url: location.href,
             type: 'GET',
             dataType: 'json',
             data: {path: '000'}
         })
         .always(function(data){
           var count = 0;
                 $(data).each(function(){
                     if(this.confirm === false){
                        count += 1;
                     }
                 });
                 if(count === 0){
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

     function aggregate(){
        var turn_id = $('#turncount').data('id');
        $.ajax({   url: location.href,
                   type: 'GET',
                   dataType: 'json',
                   data: {path: '001'}
                 })

        .always(function(data){
            $(data).each(function(){
              //表示しているターンが違うなら更新
                if(this.count !== turn_id ){
                    reload();
                }
                if(session_id === this.turn_player_id && this.player === (this.maru+this.batu+1)){
                    btnVisibility('judge_btn');
                }else if(session_id !== this.turn_player_id){
                  //確定ボタンが押されたら「○」「×」ボタンがでる。
                    if(this.confirm === true){
                        btnVisibility('maru_btn');
                        btnVisibility('batu_btn');
                    }else{
                        btnHidden('maru_btn');
                        btnHidden('batu_btn');
                    }
                }



            });
        })

     }

  });
}
