$(document).on('turbolinks:load', function(){ //リロードしなくてもjsが動くようにする

    //インクリメンタルサーチ　銘柄コードの入力フォームから値を受け取りserchアクションへ渡す処理
    $(document).on('keyup', '#stock_serch', function(e){ //このアプリケーション(document)の、stock_codeというid('#stock_code')で、キーボードが押され指が離れた瞬間(.on('keyup'...))、eという引数を取って以下のことをしなさい(function(e))
      e.preventDefault(); //キャンセル可能なイベントをキャンセル
      var input = $.trim($(this).val()); //この要素に入力された語句を取得し($(this).val())、前後の不要な空白を取り除いた($.trim(...);)上でinputという変数に(var input =)代入
      $.ajax({ //ajax通信で以下のことを行います
        url: '/stocks/search', //urlを指定
        type: 'GET', //メソッドを指定
        data: ('keyword=' + input), //コントローラーに渡すデータを'keyword=input(入力された文字のことですね)'にするように指定
        processData: false, //おまじない
        contentType: false, //おまじない
        dataType: 'json' //データ形式を指定
      })
      
      //インクリメンタルサーチ　serchアクションから受け取ったデータをビューに表示する処理
      .done(function(data){ //データを受け取ることに成功したら、dataを引数に取って以下のことする(dataには@usersが入っている状態ですね)
        $('#is_tag').find('.is_stock').remove();  //idがis_tagの子要素のliを削除する　入力文字数が１文字ずつ増えるごとに過去データを削除する
        
        if(data != null && data != "undefined"){
          $(data).each(function(i, user){ //dataをuserという変数に代入して、以下のことを繰り返し行う(単純なeach文ですね)
            //is_tagというidの要素に対して、<li>ユーザーの名前</li>を追加する。銘柄名を格納したliタグをclass = "stock_name"で１つずつ生成
            $('#is_tag').append(
              '<div class = "is_stock" style="width: 400px;" >' + 
                '<div class = "is_code">' + user.stock_code + '</div>' + 
                '<div class = "is_name">' + user.stock_name + '</div>' + 
                '<div class = "is_market">' + "@" + user.market_category + '</div>' + 
              '</div>') 
          });
          //インクリメンタルサーチ全体に外枠線をつける
          $('#is_tag').css('display','block');
          $('#is_tag').css('border','1px solid lightgrey');
        }else{
          //$('#is_tag').css('border','none');
        }

        //インクリメンタルサーチにマウスカーソルが乗った時の処理
        $('#is_tag').hover(
          function() {
            //マウスカーソルが重なった時の処理
            //$(this).css('background-color', 'red');
          },
          function() {
            //マウスカーソルが離れた時の処理
            //$('#is_tag').css('border','none');
            $('#is_tag').css('display','none');
            $('#is_tag').find('.is_stock').remove();  
          }
        );
      })
    });
    
    //インクリメンタルサーチ内をクリックした時の処理
    $(document).on('click', '.is_stock', function(){
        var input = $(this).text();
        //文字の切り出し
        var stock_code = input.slice(0,4);
        var stock_name = input.slice(4);
        
        //上場市場名抜き出し
        var count = 0;
        while(stock_name.charAt(count) != "@"){
          count++;
        }
        count++;
        var market_category = stock_name.slice(count);

        //銘柄名抜き出し
        count--;
        stock_name = stock_name.slice(0,count);

        $('#stock_code-view').text("[" + stock_code + "]");
        $('#stock_name-view').text(stock_name);
        $('#market_category-view').text(market_category);
        $('#stock_code').val(stock_code);
        $('#market_category').val(market_category);
        $('#stock_name').val(stock_name);
        $('#is_tag').find('.is_stock').remove();
        $('#is_tag').css('border','none');

        $('#stock_serch').css('background-color','lightgray');
        $('#stock_serch').val("");
        $('#stock_serch').removeAttr('placeholder');
    });

    //銘柄検索後に灰色になったフォームを白に戻す
    $(document).on('focus', '#stock_serch', function(){
      $('#stock_serch').css('background-color','white');
    });
    //遊び
    //$('li').hover(
    //    function() {
    //        //マウスカーソルが重なった時の処理
    //        $(this).css('background-color', 'red');
    //    },
    //    function() {
    //        //マウスカーソルが離れた時の処理
    //        $(this).css('background-color', 'white');
    //        
    //    }
    //);
    
    // 「new.html.erb」の手数料・諸経費ラジオボタンのチェックの有無により入力フォームを変更
    //単価種別のラジオボタンが変更されたら発火
    $('.new-pt-radio').change(function() {
      var element = document.getElementById("new-pt-radio1") ;
      if ( element.checked ) {
        //「含める」にチェックされている
          $("#new-fee-form").prop('disabled', true);
          $('#new-fee-form').css('background-color','lightgray');
          $('#new-fee-form').val("");
      } else {
        //「含める」にチェックされていない
          $("#new-fee-form").prop('disabled', false);
          $('#new-fee-form').css('background-color','white');
      }
    });

    // liquidation.html.erb決済種別ラジオボタンのチェックの有無により決済数量入力フォームを変更
    //決済種別のラジオボタンが変更されたら発火
    $('.liquidation_type').change(function() {
      var element = document.getElementById("liquidation_type1") ;
      if ( element.checked ) {
        //「全決済」にチェックされている
          $("#li-owned_quantity").prop('disabled', true);
          $('#li-owned_quantity').css('background-color','lightgray');
          var input = $.trim($('#liquidation_type').val());
          $('#li-owned_quantity').val(input);
      } else {
        // 「全決済」にチェックされていない
          $("#li-owned_quantity").prop('disabled', false);
          $('#li-owned_quantity').css('background-color','white');
          $('#li-owned_quantity').val("");
      }
    });
    
    // liquidation.html.erb手数料・諸経費ラジオボタンのチェックの有無により入力フォームを変更
    //手数料のラジオボタンが変更されたら発火
    $('.li-pt-radio').change(function() {
      var element = document.getElementById("li-pt-radio1") ;
      if ( element.checked ) {
        //「含める」にチェックされている
          $("#li-fee-form").prop('disabled', true);
          $('#li-fee-form').css('background-color','lightgray');
          $('#li-fee-form').val("");
      } else {
        //「含める」にチェックされていない
          $("#li-fee-form").prop('disabled', false);
          $('#li-fee-form').css('background-color','white');
      }
    });

    //「increase.html.erb」の手数料・諸経費ラジオボタンのチェックの有無により入力フォームを変更
    //単価種別のラジオボタンが変更されたら発火
    $('.in-pt-radio').change(function() {
      var element = document.getElementById("in-pt-radio1") ;
      if ( element.checked ) {
        //「含める」にチェックされている
          $("#in-fee-form").prop('disabled', true);
          $('#in-fee-form').css('background-color','lightgray');
          $('#in-fee-form').val("");
      } else {
        //「含める」にチェックされていない
          $("#in-fee-form").prop('disabled', false);
          $('#in-fee-form').css('background-color','white');
      }
    });

    // dividend.html.erb配当対象株数ラジオボタンの変更により配当対象株数入力フォームを変更
    //配当対象株数のラジオボタンが変更されたら発火
    $('.dividend_target').change(function() {
      var element = document.getElementById("dividend_target1") ;
      if ( element.checked ) {
        //「全保有株」にチェックされている
          $("#dividend_quantity").prop('disabled', true);
          $('#dividend_quantity').css('background-color','lightgray');
          var input = $.trim($('#liquidation_type').val());
          $('#dividend_quantity').val(input);
      } else {
        // 「全保有株」にチェックされていない
          $("#dividend_quantity").prop('disabled', false);
          $('#dividend_quantity').css('background-color','white');
          $('#dividend_quantity').val("");
      }
    });

    // edit.html.erb手数料・諸経費ラジオボタンのチェックの有無により入力フォームを変更
    //単価種別のラジオボタンが変更されたら発火
    $('.edit-pt-radio').change(function() {
      var element = document.getElementById("edit-pt-radio1") ;
      if ( element.checked ) {
        //「含める」にチェックされている
          $("#edit-fee-form").prop('disabled', true);
          $('#edit-fee-form').css('background-color','lightgray');
          $('#edit-fee-form').val("");
      } else {
        //「含める」にチェックされていない
          $("#edit-fee-form").prop('disabled', false);
          $('#edit-fee-form').css('background-color','white');
      }
    });

    //保有銘柄表のレコードからのリンク処理
    jQuery(function($){
      $('tbody .tr_possession[data-href]').addClass('clickable').click(function(){
        window.location = $(this).attr('data-href');
      }).find('a').hover(function(){
        $(this).parents('.tr_possession').unbind('click');
      },function(){
        $(this).parents('.tr_possession').click(function(){
          window.location = $(this).attr('data-href');
        });
      });
    });

    //
    $(document).on('click', '.tab-bedman', function(){
      $('.light-bedman').css('display','none');
      $('.dark-bedman').css('display','inline');
    });
    $(document).on('click', '.tab-no-bedman', function(){
      $('.dark-bedman').css('display','none');
      $('.light-bedman').css('display','inline');         
    });
    
    //operation.html.erbでタブボタンが押されたら該当のフォームを表示
    //$(document).on('click', '.liquidation-tab', function(){
    //  $('.increase').css('display','none');
    //  $('.split_consolidation').css('display','none');
    //  $('.edit').css('display','none');
    //  $('.destroy').css('display','none');
    //  $('.liquidation').css('display','block');
    //});
    //$(document).on('click', '.increase-tab', function(){
    //  $('.split_consolidation').css('display','none');
    //  $('.edit').css('display','none');
    //  $('.destroy').css('display','none');
    //  $('.liquidation').css('display','none');
    //  $('.increase').css('display','block');
    //});
    //$(document).on('click', '.split_consolidation-tab', function(){
    //  $('.increase').css('display','none');
    //  $('.edit').css('display','none');
    //  $('.destroy').css('display','none');
    //  $('.liquidation').css('display','none');
    //  $('.split_consolidation').css('display','block');
    //});
    //$(document).on('click', '.edit-tab', function(){
    //  $('.increase').css('display','none');
    //  $('.destroy').css('display','none');
    //  $('.liquidation').css('display','none');
    //  $('.split_consolidation').css('display','none')
    //  $('.edit').css('display','block');
    //});
    //$(document).on('click', '.destroy-tab', function(){
    //  $('.increase').css('display','none');
    //  $('.split_consolidation').css('display','none');
    //  $('.edit').css('display','none');
    //  $('.liquidation').css('display','none');      
    //  $('.destroy').css('display','block');
    //});

    var today = new Date();

    //new.html.erbのカレンダー表示 これを書かないと最初の読み込み時にdatepickerが起動しない
    $(document).on('click', '#new-input-date', function(){
      $(this).datepicker({
        dateFormat: 'yy/mm/dd',
        maxDate: today
      });
      $(this).datepicker("show");
    });
    //liquidation.html.erbのカレンダー表示
    $(document).on('click', '#liquidation-input-date', function(){
      var s_date = new Date($.trim($('#start_date_info').text()));
      $(this).datepicker({
        dateFormat: 'yy/mm/dd',
        minDate: s_date,
        maxDate: today
      });
      $(this).datepicker("show");
    });
    //divident.html.erbのカレンダー表示
    $(document).on('click', '#dividend-input-date', function(){
      var s_date = new Date($.trim($('#start_date_info').text()));
      $(this).datepicker({
        dateFormat: 'yy/mm/dd',
        minDate: s_date,
        maxDate: today
      });
      $(this).datepicker("show");
    });
    
    //edit.html.erbのカレンダー表示
    $('#edit-input-date').datepicker({
      dateFormat: 'yy/mm/dd',
      maxDate: today
    });
    //edit_e.html.erbのカレンダー表示
    $(document).on('click', '#edit_e-input-date', function(){
      var s_date = new Date($.trim($('#start_date_info').text()));
      $(this).datepicker({
        dateFormat: 'yy/mm/dd',
        minDate: s_date,
        maxDate: today
      });
      $(this).datepicker("show");
    });
    
    //divident_edit.html.erbのカレンダー表示
    $(document).on('click', '#dividend_edit-input-date', function(){
      $(this).datepicker({
        dateFormat: 'yy/mm/dd',
        maxDate: today
      });
      $(this).datepicker("show");
    });   

    //divident.html.erbの計算ボタン押下時の処理
    $(document).on('click', '#calculation-button', function(){
      var dividend_quantity = $.trim($('#dividend_quantity').val());
      var dividend_price = $.trim($('#dividend_price').val());
      var dividend_amount = dividend_quantity * dividend_price;
      $('#dividend_amount').val(Math.round(dividend_amount));
    });

    //銘柄詳細情報表示の銘柄名の文字サイズ調整　画面が読み込まれたら発火
    jQuery(document).ready(function(){
      var stock_name = $.trim($('#pi-stock_name').text());
      if(stock_name.length == 16){
        $('#pi-stock_name').css('font-size','17px');
      }else if(stock_name.length == 17){
        $('#pi-stock_name').css('font-size','16px');
      }else if(stock_name.length == 18){
        $('#pi-stock_name').css('font-size','15px');
      }else if(stock_name.length == 19){
        $('#pi-stock_name').css('letter-spacing','7px');
        $('#pi-stock_name').css('font-size','18px');
      }else if(stock_name.length == 20){
        $('#pi-stock_name').css('letter-spacing','6px');
        $('#pi-stock_name').css('font-size','18px');
      }else if(stock_name.length == 21){
        $('#pi-stock_name').css('letter-spacing','6px');
        $('#pi-stock_name').css('font-size','18px');
      }else if(stock_name.length == 22){
        $('#pi-stock_name').css('letter-spacing','6px');
        $('#pi-stock_name').css('font-size','18px');
      }
    });
 
});