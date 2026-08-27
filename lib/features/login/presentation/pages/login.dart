import 'package:flutter/material.dart';
import 'package:natyapp/core/components/textFieldNaty.dart';
import 'package:natyapp/core/router/app_routes.dart';
import 'package:natyapp/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Text("LOGIN",style: TextStyle(
              fontSize: 25,
            ),),
            TextFieldNaty(onChanged: (value){}, label: "Usuario/Email",),
            TextFieldNaty(onChanged: (value){}, label:  "Senha",),
            GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed(AppRoute.home.path);
              },
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(20)
                ),
                child:
                Center(
                    child: Text("Iniciar Aprendizado!", style: TextStyle(
                        fontSize:17,
                        fontWeight: FontWeight.bold
                      ),
                    )
                ) ,
              ),
            )
          ],
        ),
      ),
    ) ;
  }
}
