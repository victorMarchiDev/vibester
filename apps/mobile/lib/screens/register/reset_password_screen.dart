import 'package:flutter/material.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:mobile/widgets/buttons/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.darkGrey,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            //Cabeçalho da pagina
            children: [
              Center(
                child: SizedBox(
                  width: 130,
                  height: 265,
                  child: Image.asset('assets/img/mascote/mascote.png'),
                ),
              ),

              Text(
                'Recuperar Vibe',
                style: context.typography.displayLarge.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                'Informe e confirme sua nova senha abaixo',
                style: context.typography.bodyMedium.copyWith(
                  color: context.colors.grey,
                ),
              ),

              SizedBox(height: 15),

              //Nova senha a ser digitada
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 290, bottom: 10),
                    child: Text(
                      'SENHA',
                      style: context.typography.labelSmall.copyWith(
                        color: context.colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      obscureText: true,
                      style: context.typography.bodyLarge.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      cursorColor: context.colors.ambar,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.colors.darkGrey,
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        errorStyle: context.typography.bodySmall.copyWith(
                          color: context.colors.error,
                          fontSize: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.border,
                            width: 1.3,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.ambar,
                            width: 1.3,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.error,
                            width: 1.3,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.error,
                            width: 1.3,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a nova senha!';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              //Confirmação da nova senha digitada
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 230, bottom: 10),
                    child: Text(
                      'CONFIRMA SENHA',
                      style: context.typography.labelSmall.copyWith(
                        color: context.colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      obscureText: true,
                      style: context.typography.bodyLarge.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      cursorColor: context.colors.ambar,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.colors.darkGrey,
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        errorStyle: context.typography.bodySmall.copyWith(
                          color: context.colors.error,
                          fontSize: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.border,
                            width: 1.3,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.ambar,
                            width: 1.3,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.error,
                            width: 1.3,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: context.colors.error,
                            width: 1.3,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe novamente a nova senha!';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Botão que dispara a ação
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: SizedBox(
                      width: 350,
                      height: 50,
                      child: PrimaryButton(
                        label: 'Confirmar Senha',
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          // A tela de login ja esta na pilha (login ->
                          // recover -> reset); volta ate ela em vez de
                          // empilhar uma segunda instancia.
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName(AppRoutes.login),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
