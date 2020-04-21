const emojis = Array.from(document.getElementsByClassName('emoji'));

const copyToClipBoard = (text) => {
    navigator.clipboard.writeText(text);
}

emojis.forEach(emoji => {

    emoji.addEventListener(
        'click', (event) => {
        let contentBefore = getComputedStyle(emoji, ':before').getPropertyValue('content').replace('"', '').replace('"', '');
        copyToClipBoard(contentBefore);
        }
    );

    emoji.getElementsByTagName('sup')[0].addEventListener(
        'click', (event) => {
            event.stopPropagation();
            let className = event.target.parentElement.classList[1];
            copyToClipBoard(className);
        }
    );
});
