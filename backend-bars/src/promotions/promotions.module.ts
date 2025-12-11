import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PromotionsController } from './promotions.controller';
import { PromotionsService } from './promotions.service';
import { Promotion, PromotionSchema } from './promotion.schema';
import { BarsModule } from '../bars/bars/bars.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Promotion.name, schema: PromotionSchema }]),
    BarsModule, // Para validar ownership
  ],
  controllers: [PromotionsController],
  providers: [PromotionsService],
  exports: [PromotionsService],
})
export class PromotionsModule {}
