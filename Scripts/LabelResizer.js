function ResizeMultiLine() {
    let _multiLineTextArray = window.parent.document.getElementsByClassName("multilinestringcontrol-read");

    for (let i = 0; i < _multiLineTextArray.length; i++) {
        const _element = _multiLineTextArray[i];
        if (_element.textContent != "") {
            var _styleHeight = _element.style.height.replace("px", "");
            _styleHeight = parseInt(_styleHeight);
            if (_styleHeight < _element.scrollHeight)
                _element.style.height = (_element.scrollHeight + 1) + "px";
        }
    }
}

ResizeMultiLine();