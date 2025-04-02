
import 'package:flutter/material.dart';
import 'package:menu2/menu/view/menu_detail_view.dart';
import 'package:menu2/menu/view/menu_list_view.dart';
import 'package:menu2/menu/view/menu_create_view.dart';
import 'package:menu2/ingredient/view/ingredient_list_view.dart';


 List<Widget> pages = [
      MenuList(),
      IngredientList(),
      MenuList(),
      MenuDetailView(),
      MenuCreateView(),
  ];

  //カテゴリーの設定
final List<String> tabs = [
  '全て',
  '夕食',
  '予定',
  'お気に入り', 
  'メイン',
  '汁物',
  '麺類',
  'デザート',
  'ご飯もの'
];

final Map<String, int> tagToTabindex =
{
  'メイン': 4,
  '汁物':5,
  '麺類':6,
  'デザート':7,
  'ご飯もの':8
};
