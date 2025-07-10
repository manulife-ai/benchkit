import { Schema, model } from "mongoose";

export interface IUser {
  _id?: string;
  email: string;
  name: string;
  role: "admin" | "user" | "reviewer";
  azureId?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

const userSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    role: {
      type: String,
      enum: ["admin", "user", "reviewer"],
      default: "user",
    },
    azureId: {
      type: String,
      required: false,
      unique: true,
      sparse: true, // This allows multiple null/undefined values
    },
  },
  {
    timestamps: true,
  },
);

export default model<IUser>("User", userSchema);
