// src/menus/dto/create-menu.dto.ts
import { IsString, IsOptional, IsMongoId, ValidateNested, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';

class MenuItemDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNumber()
  price: number;

  @IsOptional()
  @IsString()
  photoUrl?: string;
}

export class CreateMenuDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsMongoId()
  barId: string;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => MenuItemDto)
  items?: MenuItemDto[];

  @IsOptional()
  @IsString()
  photoUrl?: string;
}
