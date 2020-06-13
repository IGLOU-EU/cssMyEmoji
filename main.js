const emojis = Array.from(document.getElementsByClassName('emoji'));

const copyToClipBoard = (text) => {
    navigator.clipboard.writeText(text);
    console.log('copied');
}

const infoClipBoard = (text) => {
    info.classList.add('active');
    info.textContent = `'${text}' copied to clipboard`;
    setTimeout( () => {
        info.classList.remove('active');
    }, 2000);
}

emojis.forEach(emoji => {

    emoji.addEventListener(
        'click', (event) => {
        let contentBefore = getComputedStyle(emoji, ':before').getPropertyValue('content').replace('"', '').replace('"', '');
        copyToClipBoard(contentBefore);
        infoClipBoard(contentBefore);
        }
    );

    emoji.getElementsByTagName('sup')[0].addEventListener(
        'click', (event) => {
            event.stopPropagation();
            let className = event.target.parentElement.classList[1];
            copyToClipBoard(className);
            infoClipBoard(className);
        }
    );

    const info = document.getElementById("info");
});

