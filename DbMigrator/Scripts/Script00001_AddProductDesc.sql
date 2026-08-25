IF COL_LENGTH('Product', 'ProductDesc') IS NULL
BEGIN
    ALTER TABLE [Product] ADD [ProductDesc] nvarchar(max) NULL;
END;
