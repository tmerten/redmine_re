$(document).ready(function () {
    $('form.rating').change(function () {
        $('form.rating').submit();
    });
});

$(function () {
    var checkedId = $('form.rating > input:checked').attr('id');
    $('form.rating > label[for=' + checkedId + ']').prevAll().andSelf().addClass('bright');
});

$(document).ready(function () {
    $('form.rating > label').hover(
        function () {
            $(this).prevAll().andSelf().addClass('glow');
        }, function () {
            $(this).siblings().andSelf().removeClass('glow');
        });

    $('form.rating > label').click(function () {
        $(this).siblings().removeClass("bright");
        $(this).prevAll().andSelf().addClass("bright");
    });

    $('form.rating').change(function () {
        $('form.rating').submit();
    });
});