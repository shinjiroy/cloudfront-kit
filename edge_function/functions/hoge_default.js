function handler(event) {
    var request = event.request;

    // 何か処理があれば

    // 豆知識
    // requestの中身(cookieやheader)が多いとそれだけreturn requestするタイミングでコンピューティング使用率が多くなります。
    // あんまり多すぎて遅い場合は、フィルタリングするなりすると改善が期待できます。
    return request;
}
