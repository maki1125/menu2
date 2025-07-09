import 'package:flutter/material.dart';
import 'package:menu2/common/common_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/plan/view/dinner_list_view.dart';

class PlanList extends ConsumerStatefulWidget{
  const PlanList({super.key});
  @override
  ConsumerState<PlanList> createState() => PlanListState();
}

class  PlanListState extends ConsumerState<PlanList>{

  @override
  Widget build(BuildContext context) {
    //final dispIngs = ref.watch(dispIngsProvider);
    //final viewModel = ref.read(ingViewModelProvider);


    return 
    //Scaffold(
      //appBar:AppBar(title: const Text("献立")),
      //body:
    
    Stack(//フローティングボタン配置のため
      children: [
    Column(
       children: [
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,//等間隔（両端空間あり）
          children: [

            

customButton(
  text: '今日の献立', 
  backgroundColor: Colors.orange,
  fixedSize:const Size(100, 100),
  
  onPressed: (){
    ref.read(pageIndexProvider.notifier).state = 0;
    ref.read(bottomBarIndexProvider.notifier).state = 0;
    ref.read(menuToptabIndexProvider.notifier).state = 1;
  }
        ),

        customButton(
  text: '夕食の履歴', 
  backgroundColor: Colors.orange,
  fixedSize:const Size(100, 100),
  onPressed: (){

    //ref.read(pageIndexProvider.notifier).state = 3;
    Navigator.push(//AndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DinnerList()),
      //(Route<dynamic> route) => false, // 条件を false にしてすべて削除
    );


  }),

/*
  customButton(
  text: '突撃！\n隣の晩御飯', 
  backgroundColor: Colors.grey,
  fixedSize:const Size(100, 100),
  onPressed: (){

  }),
*/

          ],
        ),

        const SizedBox(height: 20),


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,//等間隔（両端空間あり）
          children: [

            

customButton(
  text: '予定', 
  backgroundColor: Colors.orange,
  fixedSize:const Size(100, 100),
  
  onPressed: (){
    ref.read(pageIndexProvider.notifier).state = 0;
    ref.read(bottomBarIndexProvider.notifier).state = 0;
    ref.read(menuToptabIndexProvider.notifier).state = 2;
  }
        ),

/*
        customButton(
  text: '買い物リスト(準備中)', 
  backgroundColor: Colors.grey,
  fixedSize:const Size(100, 100),
  onPressed: (){
    
  }),
*/
  const SizedBox(height: 100, width: 100,),


          ],
        )
        
       ]
    )
      ]

      );

  //bottomNavigationBar: const CustomBottomBar(),
    //);
  }
}