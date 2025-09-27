import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { BarsModule } from './bars/bars/bars.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { MenusModule } from './menus/menus.module'; // <-- Importa el módulo menús

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: process.env.NODE_ENV === 'docker' ? '.env.docker' : '.env',
    }),
    MongooseModule.forRoot(process.env.MONGO_URI!),
    BarsModule,
    UsersModule,
    AuthModule,
    MenusModule, // <-- Agrega aquí
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
