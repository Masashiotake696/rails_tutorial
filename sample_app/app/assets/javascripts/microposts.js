$(function() {
  // テキストエリアの残り文字数を表示
  $('#micropost_content').on('keyup change', function () {
    $('#remaining').text(140 - $('#micropost_content').val().length);
  })
})