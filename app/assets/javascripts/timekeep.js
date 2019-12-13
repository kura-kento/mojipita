'use strict';
{
  const timer = document.getElementById('timer');

  let startTime = Date.now();
  let timeoutId;
  let elapsedTime = 0;


  function countDown(){
      const d = new Date(120000-(Date.now()- startTime + elapsedTime));
      const m = d.getMinutes();
      const s = d.getSeconds()+ (m*60);
      timer.textContent = `${String(s).padStart(3,'0')}`;

      if(s === 0){
       //クリック関数をしようしてドローする。
       document.getElementById('timeout_btn').click();
      }else{
          timeoutId = setTimeout(() => {
            countDown();
          },10);
      }
  }

  var timerStop = function(){
    clearTimeout(timeoutId);
    elapsedTime +=  Date.now() - startTime ;
  }

  var timerRestart = function(){
    countDown();
    startTime = Date.now();
  }
  countDown();

}
