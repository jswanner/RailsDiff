window.onload = function () {
  var form = document.getElementById('form');
  form.onsubmit = function () {
    var source = this.source,
        source = source.options[source.selectedIndex].value,
        target = this.target,
        target = target.options[target.selectedIndex].value,
        href   = ['html/v', source, '-v', target, '.html'].join('');
    window.location.href = href;
    return false;
  };
};
