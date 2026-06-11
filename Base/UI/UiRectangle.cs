using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using ProjectZ.InGame.Things;

namespace ProjectZ.Base.UI
{
    public class UiRectangle : UiElement
    {
        public Color BlurColor;
        public float Radius = 0;

        public UiRectangle(Rectangle rectangle, string elementId, string screen, Color color, Color blurColor, UiFunction update)
            : base(elementId, screen)
        {
            Rectangle = rectangle;
            BackgroundColor = color;
            BlurColor = blurColor;
            UpdateFunction = update;
        }

        public override void DrawBlur(SpriteBatch spriteBatch)
        {
            Resources.SetEffectParameter(Resources.RoundedCornerBlurEffect, "scale", Game1.UiScale);
            Resources.SetEffectParameter(Resources.RoundedCornerBlurEffect, "blurColor", BlurColor.ToVector4());
            Resources.SetEffectParameter(Resources.RoundedCornerBlurEffect, "radius", Radius);
            Resources.SetEffectParameter(Resources.RoundedCornerBlurEffect, "width", Rectangle.Width / Game1.UiScale);
            Resources.SetEffectParameter(Resources.RoundedCornerBlurEffect, "height", Rectangle.Height / Game1.UiScale);

            // draw the blur texture
            spriteBatch.Draw(Resources.SprWhite, Rectangle, BackgroundColor);
        }
    }
}