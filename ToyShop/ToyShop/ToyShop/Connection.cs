﻿using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace ToyShop
{
    public class Connection
    {
        public static string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["cs"].ConnectionString;
        }
    }
    public class Utils
    {
        SqlConnection con;
        SqlCommand cmd;
        SqlDataAdapter sda;
        public static bool IsValidExtension(string fileName)
        {

            bool isValid = false;
            string[] fileExtension = { ".jpg", ".png", ".jpeg" };
            for (int i = 0; i <= fileExtension.Length - 1; i++)
            {

                if (fileName.Contains(fileExtension[i]))
                {
                    isValid = true;
                    break;

                }

            }
            return isValid;
        }

        public static string GetImageUrl(Object url)
        {
            string url1 = "";
            if (string.IsNullOrEmpty(url.ToString()) || url == DBNull.Value)
            {
                url1 = "../Images/No_image.png";


            }
            else 
            {
                
                url1 = string.Format("../{0}", url);
                          
            
            }
            return url1;
        
        }

        public bool updateCartQuantity(int quantity, int productId, int userId)
        {
            SqlConnection con = new SqlConnection(Connection.GetConnectionString());
            SqlCommand cmd = new SqlCommand("Cart_Crud", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Action", "UPDATE");
            cmd.Parameters.AddWithValue("@ProductId", productId);
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@Quantity", quantity);

            try
            {
                con.Open();
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception ex)
            {
                // Handle error
                return false;
            }
            finally
            {
                con.Close();
            }
        }



        public int cartCount(int userId)
        {

            con = new SqlConnection(Connection.GetConnectionString());
            cmd = new SqlCommand("User_Crud", con);
            cmd.Parameters.AddWithValue("@Action", "SELECT");
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.CommandType = CommandType.StoredProcedure;
            sda = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            sda.Fill(dt);
            return dt.Rows.Count;
        }

        public static string GetUniqueId()
        {
            Guid guid = Guid.NewGuid();
            String uniqueId = guid.ToString();
            return uniqueId;
        
        
        }
    }

    public class DashboardCount
    {
        SqlConnection con;
        SqlCommand cmd;
        SqlDataReader sdr;

        public int Count(string tableName) {

            int count = 0;
            con = new SqlConnection(Connection.GetConnectionString());
            cmd = new SqlCommand("Dashboared", con);
            cmd.Parameters.AddWithValue("@Action", tableName);
            cmd.CommandType = CommandType.StoredProcedure;
            con.Open();
            sdr = cmd.ExecuteReader();
            while (sdr.Read()) 
            {
                if (sdr[0] == DBNull.Value)
                {
                    count = 0;

                }
                else {

                    count = Convert.ToInt32(sdr[0]);
                }
                
            
            }
            sdr.Close();
            con.Close();
            return count;

        }



    }
}