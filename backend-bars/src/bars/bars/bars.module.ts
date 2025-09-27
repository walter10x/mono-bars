import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { BarsService } from './bars.service';
import { BarsController } from './bars.controller';
import { Bar, BarSchema } from './bar.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: Bar.name, schema: BarSchema }])],
  controllers: [BarsController],
  providers: [BarsService],
  exports: [BarsService],  // Exportamos el servicio para que otros módulos lo puedan usar
})
export class BarsModule {}
