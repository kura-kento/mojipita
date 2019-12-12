'use strict';

{
  const timer = document.getElementById('timer');
  const start = document.getElementById('start');
  const stop = document.getElementById('stop');
  const reset = document.getElementById('reset');
  

  let startTime;
  let timeoutId;
  let elapsedTime = 0;
  timer.classList.add('timer');
  setButtonStateInitial();



  function countUp(){
      const d = new Date(60000 -(Date.now() - startTime + elapsedTime));
      const D = new Date(Date.now() - startTime + elapsedTime);
      const m = D.getMinutes();
      const s = d.getSeconds();
      const ms = d.getMilliseconds();
      timer.textContent = `${String(s).padStart(2, '0')}.${String(ms).padStart(3, '0')}`;

      if(m === 1){
        setButtonStateTimeout();
        clearTimeout(timeoutId);

        timer.textContent = '時間切れ';
        timer.classList.remove('timer');
        timer.classList.add('timeout');
      }else{
          timeoutId = setTimeout(() => {
              countUp();
          },10);
      }

    }

    function setButtonStateInitial(){
        start.classList.add('start-btn');
        start.classList.remove('inactive');
        stop.classList.add('inactive');
        reset.classList.add('inactive');
    }

    function setButtonStateRunning(){
        start.classList.add('inactive');
        start.classList.remove('start-btn');
        stop.classList.remove('inactive');
        reset.classList.add('inactive');
    }

    function setButtonStateStopped(){
        start.classList.remove('inactive');
        stop.classList.add('inactive');
        reset.classList.remove('inactive');
    }
    function setButtonStateTimeout(){
        start.classList.add('inactive');
        stop.classList.add('inactive');
        reset.classList.remove('inactive');
    }




  start.addEventListener('click',() => {
      if(start.classList.contains('inactive') === true){
          return;
      }
      setButtonStateRunning();
      startTime = Date.now();
      countUp();
  });

  stop.addEventListener('click',() => {
      if(stop.classList.contains('inactive') === true){
          return;
      }
      setButtonStateStopped();
      clearTimeout(timeoutId);
      elapsedTime += Date.now() - startTime;
  });
  reset.addEventListener('click',() => {
      if(reset.classList.contains('inactive') === true){
          return;
      }
      setButtonStateInitial();
      timer.textContent = '60.000';
      elapsedTime = 0;
      timer.classList.remove('timeout');
      timer.classList.add('timer');
  });
}
