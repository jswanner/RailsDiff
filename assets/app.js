window.onload = function () {
  var form,
      formHandler,
      forms = document.getElementsByTagName('form'),
      idx,
      match = this.location.pathname.match(/^\/html\/([^-]+)-(.+).html/),
      switchHandler,
      switches = document.getElementsByClassName('switch');

  if (match) {
    for (idx = forms.length; idx--;) {
      form = forms[idx];
      form.source.namedItem(match[1]).selected = true;
      form.target.namedItem(match[2]).selected = true;
    }
  }

  formHandler = function () {
    var source    = this.source,
        sourceVer = source.options[source.selectedIndex].value,
        target    = this.target,
        targetVer = target.options[target.selectedIndex].value,
        href      = ['/html/', sourceVer, '-', targetVer, '.html'].join('');
    window.location.pathname = href;
    return false;
  };

  for (idx = forms.length; idx--;) { forms[idx].onsubmit = formHandler }

  switchHandler = function (event) {
    var form      = this.parentNode,
        source    = form.source,
        sourceVer = source.options[source.selectedIndex].value,
        target    = form.target,
        targetVer = target.options[target.selectedIndex].value;

    source.namedItem(targetVer).selected = true;
    target.namedItem(sourceVer).selected = true;
    return false;
  };

  for (idx = switches.length; idx--;) { switches[idx].onclick = switchHandler; }
};
