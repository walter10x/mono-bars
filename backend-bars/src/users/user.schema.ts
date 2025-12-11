import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({
  timestamps: true, // Agrega createdAt y updatedAt automáticamente
  toJSON: {
    transform: function (_doc: any, ret: any) {
      ret.id = ret._id.toString();
      delete ret._id;
      delete ret.__v;
      delete ret.password; // No devolver la contraseña en las respuestas JSON
      return ret;
    },
  },
})
export class User extends Document {
  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  password: string;

  @Prop({ required: true })
  name: string;

  @Prop({ required: true, default: 'client' })
  role: 'owner' | 'client' | 'admin';
}

export const UserSchema = SchemaFactory.createForClass(User);
