window.onload = function () {
  var idx,
      switchHandler,
      forms = document.getElementsByTagName('form'),
      switches = document.getElementsByClassName('switch');

  for (idx in forms) {
    forms[idx].onsubmit = function () {
      var source    = this.source,
          sourceVer = source.options[source.selectedIndex].value,
          target    = this.target,
          targetVer = target.options[target.selectedIndex].value,
          href      = ['/html/', sourceVer, '-', targetVer, '.html'].join('');
      window.location.href = href;
      return false;
    };
  }

  switchHandler = function () {
    var form      = this.parentNode,
        source    = form.source,
        sourceVer = source.options[source.selectedIndex].value,
        target    = form.target,
        targetVer = target.options[target.selectedIndex].value;

    source.namedItem(targetVer).selected = true;
    target.namedItem(sourceVer).selected = true;
    return false;
  };

  for (idx in switches) { switches[idx].onclick = switchHandler; }
};
