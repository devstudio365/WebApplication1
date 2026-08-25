IF COL_LENGTH('Product', 'ProductActive') IS NULL
BEGIN
    ALTER TABLE [Product] ADD [ProductActive] bit NULL;
END;
