import {
  IsString,
  IsNotEmpty,
  IsUUID,
  IsDateString,
  IsInt,
  Min,
  IsOptional,
  IsEnum,
} from 'class-validator';
import { ReservationStatus } from '../reservation.schema';

export class CreateReservationDto {
  @IsUUID()
  @IsNotEmpty()
  barId: string;

  @IsDateString()
  @IsNotEmpty()
  reservationDate: string;

  @IsInt()
  @Min(1)
  numberOfPeople: number;

  @IsString()
  @IsNotEmpty()
  customerName: string;

  @IsString()
  @IsNotEmpty()
  customerPhone: string;

  @IsString()
  @IsOptional()
  comments?: string;
}

export class UpdateReservationDto {
  @IsDateString()
  @IsOptional()
  reservationDate?: string;

  @IsInt()
  @Min(1)
  @IsOptional()
  numberOfPeople?: number;

  @IsString()
  @IsOptional()
  customerName?: string;

  @IsString()
  @IsOptional()
  customerPhone?: string;

  @IsString()
  @IsOptional()
  comments?: string;

  @IsEnum(ReservationStatus)
  @IsOptional()
  status?: ReservationStatus;
}
