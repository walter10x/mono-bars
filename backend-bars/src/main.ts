import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as express from 'express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Permite servir archivos estáticos de la carpeta uploads vía URL /uploads
  app.use('/uploads', express.static(join(__dirname, '..', 'uploads')));

  // Habilitar CORS
  app.enableCors();

  // Configurar graceful shutdown para liberar el puerto correctamente
  app.enableShutdownHooks();

  await app.listen(process.env.PORT || 3000);
  console.log('JWT_SECRET:', process.env.JWT_SECRET);
  console.log(`Application is running on: http://localhost:3000`);
}
bootstrap();
