// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:piamidy_flutter/enum/navi_type_enum.dart';
// import 'package:piamidy_flutter/provider/fumen_list_provider.dart';
// import 'package:piamidy_flutter/provider/select_navi_provider.dart';
// import 'package:piamidy_flutter/provider/select_search_provider.dart';
// import 'package:piamidy_flutter/res/custom_const.dart';
// import 'package:piamidy_flutter/utils/common_util.dart';

// class SearchDialog extends HookConsumerWidget {
//   // テキストエリア
//   final controller = TextEditingController(text: '');
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 検索条件を監視（初期値はサイドナビの選択値）
//     int selectIndex = ref.watch(selectSearchProvider);

//     return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
//       AlertDialog(
//         insetPadding: const EdgeInsets.all(0),
//         content: Container(
//             width: 400.w,
//             child: TextFormField(
//               autofocus: true, // ダイアログが開いたときに自動でフォーカスを当てる
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: 'general.searchword'.tr(), // プレースホルダー
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10), // 角の丸み
//                 ), // 枠線
//               ),
//               style: TextStyle(
//                 fontSize: 15.sp,
//               ),
//             )),
//         actions: [
//           Container(
//               height: 50.w,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: <Widget>[
//                   // ホーム選択
//                   SizedBox(
//                       width: 60.w,
//                       child: IconButton(
//                         iconSize: 40.sp,
//                         icon: const Icon(Icons.home),
//                         color: selectIndex == NaviTypeEnum.HOME.num
//                             ? Colors.blue
//                             : Colors.grey,
//                         onPressed: () {
//                           ref
//                               .read(selectSearchProvider.notifier)
//                               .selectNum(NaviTypeEnum.HOME.num);
//                         },
//                       )),
//                   // 履歴選択
//                   SizedBox(
//                       width: 60.w,
//                       child: IconButton(
//                         iconSize: 40.sp,
//                         icon: const Icon(Icons.history),
//                         color: selectIndex == NaviTypeEnum.HISTORY.num
//                             ? Colors.blue
//                             : Colors.grey,
//                         onPressed: () {
//                           ref
//                               .read(selectSearchProvider.notifier)
//                               .selectNum(NaviTypeEnum.HISTORY.num);
//                         },
//                       )),
//                   // ブックマーク選択
//                   SizedBox(
//                       width: 60.w,
//                       child: IconButton(
//                         iconSize: 40.sp,
//                         icon: const Icon(Icons.bookmark),
//                         color: selectIndex == NaviTypeEnum.BOOKMARK.num
//                             ? Colors.blue
//                             : Colors.grey,
//                         onPressed: () {
//                           ref
//                               .read(selectSearchProvider.notifier)
//                               .selectNum(NaviTypeEnum.BOOKMARK.num);
//                         },
//                       )),
//                   SizedBox(width: 140.w),
//                   // 検索ボタン
//                   Container(
//                       width: 80.w,
//                       height: 70.h,
//                       decoration: BoxDecoration(
//                         color: Colors.blue,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: IconButton(
//                         icon: Icon(Icons.search, size: 30.sp),
//                         iconSize: 16.sp,
//                         color: Colors.white,
//                         onPressed: () {
//                           // 検索キーワード設定
//                           CustomConst.searchWord = editKeyword(controller.text);
//                           // 検索処理
//                           ref.invalidate(fumenListProvider);
//                           // サイドナビ更新
//                           if (selectIndex == NaviTypeEnum.HISTORY.num) {
//                             CustomConst.selectNavi = NaviTypeEnum.HISTORY;
//                           } else if (selectIndex == NaviTypeEnum.BOOKMARK.num) {
//                             CustomConst.selectNavi = NaviTypeEnum.BOOKMARK;
//                           } else {
//                             CustomConst.selectNavi = NaviTypeEnum.HOME;
//                           }
//                           ref
//                               .read(selectNaviProvider.notifier)
//                               .select(CustomConst.selectNavi.num);
//                           Navigator.pop(context);
//                         },
//                       ))
//                 ],
//               ))
//         ],
//       )
//     ]);
//   }

//   // 検索キーワード編集
//   String editKeyword(String keyword) {
//     // 初期トリム処理
//     String text = keyword.replaceAll('　', ' ').trim();
//     if (text.isNotEmpty) {
//       // ブランクではない場合
//       if (text.contains(' ')) {
//         // 半角空白を含む
//         text = text.split(' ')[0];
//       } else if (text.contains('　')) {
//         // 全角文字列を含む
//         text = text.split('　')[0];
//       }
//     }
//     return text;
//   }
// }
