// src/common/services/resend.service.ts
import { Injectable } from '@nestjs/common';
import { Resend } from 'resend';

@Injectable()
export class ResendService {
  private resend: Resend | null = null;
  private fromEmail: string;
  private frontendUrl: string;
  private isConfigured: boolean = false;

  constructor() {
    // Get configuration from environment variables
    const apiKey = process.env.RESEND_API_KEY;
    const fromEmail = process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev';
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3000';

    this.fromEmail = fromEmail;
    this.frontendUrl = frontendUrl;

    if (!apiKey) {
      console.warn('⚠️ RESEND_API_KEY no encontrada en .env. El envío de emails no funcionará.');
      console.warn('📝 Para configurar, agrega RESEND_API_KEY=tu_api_key en el archivo .env');
      this.isConfigured = false;
    } else {
      this.resend = new Resend(apiKey);
      this.isConfigured = true;
      console.log('✅ ResendService configurado correctamente');
    }
  }

  /**
   * Envía un email de recuperación de contraseña
   */
  async sendPasswordResetEmail(email: string, resetToken: string): Promise<void> {
    // Verificar si el servicio está configurado
    if (!this.isConfigured || !this.resend) {
      console.error('❌ ResendService no está configurado. Agrega RESEND_API_KEY en .env');
      console.log('📧 [MODO DESARROLLO] Token de reset para', email, ':', resetToken);
      console.log('🔗 URL de reset:', `${this.frontendUrl}/reset-password?token=${resetToken}`);
      // En desarrollo, no lanzar error para permitir pruebas
      return;
    }

    try {
      const resetUrl = `${this.frontendUrl}/reset-password?token=${resetToken}`;

      const { data, error } = await this.resend.emails.send({
        from: this.fromEmail,
        to: email,
        subject: 'Recuperación de Contraseña - TourBar',
        html: this.getPasswordResetEmailTemplate(resetUrl),
      });

      if (error) {
        console.error('❌ Error al enviar email con Resend:', error);
        throw new Error(`Error al enviar email: ${error.message}`);
      }

      console.log('✅ Email de recuperación enviado exitosamente:', data);
    } catch (error) {
      console.error('❌ Error al enviar email de recuperación:', error);
      throw error;
    }
  }

  /**
   * Template HTML para el email de recuperación de contraseña
   */
  private getPasswordResetEmailTemplate(resetUrl: string): string {
    return `
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Recuperación de Contraseña</title>
      </head>
      <body style="margin: 0; padding: 0; font-family: 'Arial', sans-serif; background-color: #0F0F1E;">
        <table role="presentation" style="width: 100%; border-collapse: collapse;">
          <tr>
            <td align="center" style="padding: 40px 0;">
              <table role="presentation" style="width: 600px; border-collapse: collapse; background-color: #1E1E2D; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);">
                <!-- Header -->
                <tr>
                  <td style="background: linear-gradient(135deg, #1A1A2E 0%, #16213E 100%); padding: 40px; text-align: center;">
                    <h1 style="margin: 0; color: #FFA500; font-size: 32px; font-weight: bold; letter-spacing: 2px;">TourBar</h1>
                    <p style="margin: 10px 0 0 0; color: #FFB84D; font-size: 14px; letter-spacing: 1px;">Tu guía para la mejor experiencia</p>
                  </td>
                </tr>
                
                <!-- Content -->
                <tr>
                  <td style="padding: 40px;">
                    <h2 style="margin: 0 0 20px 0; color: #FFFFFF; font-size: 24px; font-weight: bold;">Recuperación de Contraseña</h2>
                    <p style="margin: 0 0 20px 0; color: #B0B0C0; font-size: 16px; line-height: 1.6;">
                      Hemos recibido una solicitud para restablecer la contraseña de tu cuenta en TourBar.
                    </p>
                    <p style="margin: 0 0 30px 0; color: #B0B0C0; font-size: 16px; line-height: 1.6;">
                      Para restablecer tu contraseña, haz clic en el siguiente botón:
                    </p>
                    
                    <!-- Button -->
                    <table role="presentation" style="width: 100%; border-collapse: collapse;">
                      <tr>
                        <td align="center" style="padding: 20px 0;">
                          <a href="${resetUrl}" style="display: inline-block; padding: 16px 40px; background: linear-gradient(135deg, #FFA500 0%, #FFB84D 100%); color: #1A1A2E; font-size: 16px; font-weight: bold; text-decoration: none; border-radius: 12px; letter-spacing: 1px; box-shadow: 0 4px 15px rgba(255, 165, 0, 0.4);">
                            RESTABLECER CONTRASEÑA
                          </a>
                        </td>
                      </tr>
                    </table>
                    
                    <p style="margin: 30px 0 20px 0; color: #B0B0C0; font-size: 14px; line-height: 1.6;">
                      Si el botón no funciona, copia y pega este enlace en tu navegador:
                    </p>
                    <p style="margin: 0 0 30px 0; padding: 15px; background-color: #16213E; border-radius: 8px; word-break: break-all; color: #FFB84D; font-size: 13px; font-family: monospace;">
                      ${resetUrl}
                    </p>
                    
                    <!-- Warning Box -->
                    <div style="margin: 30px 0; padding: 20px; background-color: rgba(255, 165, 0, 0.1); border-left: 4px solid #FFA500; border-radius: 8px;">
                      <p style="margin: 0; color: #FFA500; font-size: 14px; font-weight: bold;">⚠️ Importante:</p>
                      <p style="margin: 10px 0 0 0; color: #B0B0C0; font-size: 14px; line-height: 1.6;">
                        Este enlace expirará en <strong style="color: #FFA500;">1 hora</strong> por seguridad. Si no solicitaste este cambio, puedes ignorar este email.
                      </p>
                    </div>
                    
                    <p style="margin: 0; color: #808090; font-size: 13px; line-height: 1.6;">
                      Si no solicitaste restablecer tu contraseña, puedes ignorar este email de forma segura.
                    </p>
                  </td>
                </tr>
                
                <!-- Footer -->
                <tr>
                  <td style="background-color: #16213E; padding: 30px; text-align: center; border-top: 1px solid rgba(255, 165, 0, 0.2);">
                    <p style="margin: 0; color: #808090; font-size: 13px;">
                      © 2025 TourBar. Todos los derechos reservados.
                    </p>
                    <p style="margin: 10px 0 0 0; color: #606070; font-size: 12px;">
                      Este es un email automático, por favor no respondas a este mensaje.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    `;
  }
}
