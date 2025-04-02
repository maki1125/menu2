import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/menu/view_model/menu_view_model.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/common/common_widget.dart';
import 'package:menu2/menu/data/model/menu.dart';

class MenuDetailView extends ConsumerStatefulWidget{
  @override
  ConsumerState<MenuDetailView> createState() => MenuDetailViewState();
}

class  MenuDetailViewState extends ConsumerState<MenuDetailView>{
    @override
  Widget build(BuildContext context) {
    final menu = ref.watch(menuProvider);
    Menu addmenu = Menu();
    addmenu.name = 'd';
    addmenu.userId = 'u0';
     Menu updatemenu = menu!;
    //menu.name = 'update';

    return Column(
      children: [
        Text("${menu!.name}"),

        TextButton(//枠線なしボタン。リンクっぽい？
          onPressed: () async{ 
            final bool? result = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmDialog(
                  message: 'このメニューを削除しますか？',
                ),
              );

              if (result == true) {
                ref.read(menuProvider.notifier).deleteMenu();
                ref.read(pageIndexProvider.notifier).state = 0;
              }
            
          },
          child: Text('delete'),
        ),

        TextButton(//枠線なしボタン。リンクっぽい？
          onPressed: () { 
            ref.read(menuProvider.notifier).addMenu(addmenu);
            ref.read(pageIndexProvider.notifier).state = 0;
          },
          child: Text('add'),
        ),

        TextButton(//枠線なしボタン。リンクっぽい？
          onPressed: () { 
            ref.read(menuProvider.notifier).updateMenu(updatemenu);
            ref.read(pageIndexProvider.notifier).state = 0;
          },
          child: Text('update'),
        ),

//アイコン2つ-----------------------------------------
                                    Row(
                                      children: [
                                        //編集アイコンーーーーーーーーーーーーーーーーーーーーーーー
                                                    InkWell(
                                                      borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4.0), // タッチ領域を調整
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 23,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                         ref.read(menuProvider.notifier).setMenu(menu);
                                                        ref.read(pageIndexProvider.notifier).state = 4;
                                                        }
                                                      
                                                    ),

                                          //削除アイコンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                                                    InkWell(
                                                      borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4.0), // タッチ領域を調整
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 23,
                                                        ),
                                                      ),
                                                      onTap: () async{ 
                                                        final bool? result = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => const ConfirmDialog(
                                                              message: 'このメニューを削除しますか？',
                                                            ),
                                                          );

                                                          if (result == true) {
                                                            ref.read(menuProvider.notifier).setMenu(menu);
                                                            ref.read(menuProvider.notifier).deleteMenu();
                                                            ref.read(pageIndexProvider.notifier).state = 0;
                                                          }
                                                        
                                                      },
                                                    ),

                                              //お気に入りアイコン-------------------------------
                                                    IconButton(
                                                onPressed: () {
                                                  menu.isFavorite = !(menu.isFavorite);
                                                  print("お気に入り押しました");
                                                  ref.read(menuProvider.notifier).updateMenu(menu);
                                                },
                                                icon: const Icon(Icons.favorite),
                                                color: menu.isFavorite
                                                ? Colors.pink
                                                : Colors.grey,
                                                iconSize: 25,
                                              )


                                      ]
                                    )
                                
                                

        
      ],
    );
}
}