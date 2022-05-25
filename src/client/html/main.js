const audioElement = document.querySelector('#audio');

window.addEventListener('message', ({data}) => {
    if (data.type == 'playSound') {
        const distance = data.distance;
        const volume = Math.max(0.05, ((100 - distance) / 100) - 0.85);
        audioElement.src = `audio/${data.soundFile}.mp3`;
        audioElement.volume = volume;
        audioElement.play();

        audioElement.addEventListener('ended', function() {
            audioElement.src = '';
        });
    }
});